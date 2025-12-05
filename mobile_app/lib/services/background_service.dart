import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_app/api/sos_service.dart';
import 'package:mobile_app/services/notification_service.dart';
import 'package:mobile_app/utils/api_constants.dart';

/// {@template background_service_on_start}
/// Punto de entrada para el servicio en segundo plano.
/// {@endtemplate}
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  print("🔴 BACKGROUND INICIADO"); 
  print("🔴 URL API: ${ApiConstants.baseUrl}");

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Instancia única del manejador de lógica SOS dentro de este Isolate.
  final SosTrackingService trackingService = SosTrackingService(service, flutterLocalNotificationsPlugin);

  /// Listener para iniciar el seguimiento SOS.
  service.on('startSosTracking').listen((payload) {
    if (payload != null) {
      print("BackgroundService: Iniciando SOS con data: $payload");
      trackingService.startTracking(
        durationInSeconds: payload['durationInSeconds'] ?? 600,
        emergencyContact: payload['emergencyContact'],
        token: payload['token'],
      );
    }
  });

  /// Listener para detener el seguimiento desde la UI (botón del usuario).
  service.on('stopSosFromUI').listen((payload) {
    print("BackgroundService: Deteniendo SOS desde UI");
    trackingService.stopTracking(byUser: true);
  });

  /// Listener para detener el seguimiento forzosamente desde el servidor (vía Socket).
  service.on('serverForceStop').listen((payload) {
    print("BackgroundService: Deteniendo SOS por orden del servidor");
    trackingService.stopTracking(byUser: false);
  });

  /// Listener para que la UI consulte el estado actual del SOS al reconectarse.
  service.on('getSosStatus').listen((payload) {
    trackingService.sendStatusToUI();
  });
}

/// {@template sos_tracking_service}
/// Clase que encapsula toda la lógica de estado del seguimiento SOS.
/// {@endtemplate}
class SosTrackingService {
  final ServiceInstance service;
  final FlutterLocalNotificationsPlugin notificationsPlugin;
  final SosService _apiService = SosService();
  
  Timer? _locationTimer;
  Timer? _countdownTimer;
  int? _alertId;
  int _remainingSeconds = 0;
  bool _isActive = false;
  String? _authToken;

  SosTrackingService(this.service, this.notificationsPlugin) {
    _init();
  }

  void _init() async {
    await notificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
  }

  void sendStatusToUI() {
    service.invoke('update', {
      'action': 'currentSosStatus',
      'isActive': _isActive,
      'alertId': _alertId,
      'seconds': _remainingSeconds,
    });
  }

  /// Inicia el proceso completo de seguimiento SOS.
  Future<void> startTracking({
    required int durationInSeconds,
    Map<String, dynamic>? emergencyContact,
    required String? token,
  }) async {
    _authToken = token;
    // 1. LIMPIEZA PREVIA CRÍTICA: 
    // Si había un SOS anterior mal cerrado, esto lo limpia para permitir el reinicio.
    // Usamos 'byUser: false' para indicar limpieza interna.
    await stopTracking(byUser: false, isRestart: true);

    debugPrint("BG_SERVICE: Iniciando seguimiento SOS... Duración: $durationInSeconds");
    _remainingSeconds = durationInSeconds;
    _isActive = true;

    try {
      // 2. Ubicación Inicial
      Position pos;
      try {
         pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      } catch (e) {
         print("Error GPS inicial: $e. Usando fallback.");
         pos = Position(longitude: -80.63282, latitude: -5.19449, timestamp: DateTime.now(), accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0);
      }
      
      // 3. Activar en Backend
      // Convertir mapa dinámico a estricto String, String?
      final contactMap = emergencyContact != null 
          ? Map<String, String?>.from(emergencyContact) 
          : null;

      _alertId = await _apiService.activateSos(
        lat: pos.latitude,
        lon: pos.longitude,
        durationInSeconds: durationInSeconds,
        emergencyContact: contactMap,
        token: _authToken,
      );

      if (_alertId == null || _alertId == 0) {
        throw Exception('Failed to activate on backend. Alert ID is null/0');
      }

      debugPrint("BG_SERVICE: Alerta activada con ID: $_alertId");
      
      // 4. Notificar a la UI que el SOS comenzó.
      service.invoke('update', {
        'action': 'sosStarted',
        'isActive': true,
        'alertId': _alertId,
        'seconds': _remainingSeconds,
      });
      
      _updateNotification('SOS Activo', 'Enviando ubicación...');

      // 5. Iniciar temporizador de cuenta regresiva (cada 1 seg).
      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!_isActive) {
          timer.cancel();
          return;
        }
        _remainingSeconds--;

        // Notificar UI
        service.invoke('update', {
            'action': 'updateTimer', 
            'seconds': _remainingSeconds
        });
        
        // Actualizar notificación cada 60 segundos
        if (_remainingSeconds % 60 == 0) {
             _updateNotification('SOS Activo', 'Tiempo restante: ${(_remainingSeconds ~/ 60)} min');
        }

        // Detener si el tiempo se acaba
        if (_remainingSeconds <= 0) {
          debugPrint("BG_SERVICE: Tiempo de SOS finalizado.");
          stopTracking(byUser: true); 
        }
      });

      // 6. Iniciar temporizador de envío de ubicación (cada 15 seg).
      _locationTimer?.cancel();
      _locationTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
        if (!_isActive || _alertId == null) {
          timer.cancel();
          return;
        }
        try {
          Position newPos = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
          
          await _apiService.addLocationUpdate(
            alertId: _alertId!,
            lat: newPos.latitude,
            lon: newPos.longitude,
            token: _authToken,
          );
        } catch (e) {
          debugPrint("BG_SERVICE: Error al enviar ubicación: $e");
          service.invoke('update', {'action': 'connectionLost'});
        }
      });
    } catch (e) {
      debugPrint("BG_SERVICE: Error fatal al iniciar SOS: $e");
      _isActive = false;
      service.invoke('update', {
          'action': 'sosFinished', 
          'error': e.toString()
      });
    }
  }

  /// Detiene el servicio de seguimiento SOS.
  /// [byUser]: Si es true, avisa al backend.
  /// [isRestart]: Si es true, es una limpieza interna antes de iniciar otro, no borra IDs.
  Future<void> stopTracking({bool byUser = false, bool isRestart = false}) async {
    if (!_isActive && !isRestart) return;

    _isActive = false;
    _countdownTimer?.cancel();
    _locationTimer?.cancel();
    _countdownTimer = null;
    _locationTimer = null;

    final int? alertIdToDeactivate = _alertId;
    
    // Solo limpiamos el ID si realmente estamos terminando, no reiniciando
    if (!isRestart) {
        _alertId = null;
        _remainingSeconds = 0;
    }

    // 1. Notificar al backend (si aplica).
    if (byUser && alertIdToDeactivate != null && alertIdToDeactivate > 0) {
      try {
        await _apiService.deactivateSos(alertIdToDeactivate);
        debugPrint("BG_SERVICE: Alerta $alertIdToDeactivate desactivada en backend.");
      } catch (e) {
        debugPrint("BG_SERVICE: Error al desactivar alerta: $e");
      }
    }

    // 2. Notificar a la UI y limpiar notificación
    if (!isRestart) {
        service.invoke('update', {'action': 'sosFinished'});
        notificationsPlugin.cancel(NotificationService.sosNotificationId);
    }
  }

  void _updateNotification(String title, String body) {
    notificationsPlugin.show(
      NotificationService.sosNotificationId,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationService.sosChannelId,
          'Alertas SOS',
          importance: Importance.high,
          priority: Priority.high,
          ongoing: true,
          autoCancel: false,
          color: Colors.red,
        ),
        iOS: DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true),
      ),
    );
  }
}

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: false, 
      notificationChannelId: NotificationService.sosChannelId,
      initialNotificationTitle: 'Servicio SOS listo',
      initialNotificationContent: 'Esperando activación.',
      foregroundServiceNotificationId: NotificationService.sosNotificationId,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
    ),
  );
}