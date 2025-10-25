// lib/services/background_service.dart
import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_app/api/sos_service.dart';
import 'package:mobile_app/services/notification_service.dart'; // Para el canal

// --- PUNTO DE ENTRADA DEL ISOLATE DE SEGUNDO PLANO ---
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // DartPluginRegistrant.ensureInitialized() se llama automáticamente
  
  // Crear una instancia de la lógica del servicio
  final SosTrackingService trackingService = SosTrackingService(service);

  // Escuchar invocaciones desde la UI
  service.on('startSosTracking').listen((payload) {
    if (payload != null) {
      trackingService.startTracking(
        durationInSeconds: payload['durationInSeconds'],
        emergencyContact: payload['emergencyContact'],
      );
    }
  });

  service.on('stopSosFromUI').listen((payload) {
    trackingService.stopTracking(byUser: true);
  });

  service.on('serverForceStop').listen((payload) {
    trackingService.stopTracking(byUser: false);
  });
}

// --- LÓGICA PRINCIPAL DEL SERVICIO DE SEGUIMIENTO ---
class SosTrackingService {
  final ServiceInstance service;
  final SosService _apiService = SosService();

  Timer? _locationTimer;
  Timer? _countdownTimer;
  int? _alertId;
  int _remainingSeconds = 0;

  SosTrackingService(this.service) {
    _init();
  }

  void _init() async {
    // Configurar notificación persistente
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'), // Asegúrate que este ícono exista
        iOS: DarwinInitializationSettings(),
      ),
    );
  }

  Future<void> startTracking({
    required int durationInSeconds,
    Map<String, dynamic>? emergencyContact,
  }) async {
    // Evitar doble activación
    if (_alertId != null) return;

    print("BG_SERVICE: Iniciando seguimiento SOS...");
    _remainingSeconds = durationInSeconds;

    try {
      // 1. Obtener ubicación inicial
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 2. Activar alerta en el backend
      _alertId = await _apiService.activateSos(
        lat: pos.latitude,
        lon: pos.longitude,
        durationInSeconds: durationInSeconds,
        emergencyContact: emergencyContact?.cast<String, String?>(),
      );

      if (_alertId == null) {
        print("BG_SERVICE: Error al activar SOS en el backend.");
        service.invoke('sosFinished'); // Notifica a la UI que falló
        return;
      }

      print("BG_SERVICE: Alerta activada con ID: $_alertId");

      // 3. Notificar a la UI que el SOS comenzó
      service.invoke('sosStarted', {
        'action': 'sosStarted', // <-- Añadir acción
        'alertId': _alertId,
        'seconds': _remainingSeconds,
      });
      _updateNotification('SOS Activo', 'Enviando ubicación... Tiempo restante: $_remainingSeconds s');


      // 4. Iniciar temporizador de cuenta regresiva (cada segundo)
      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _remainingSeconds--;
        
        // Notificar a la UI del tiempo restante
        service.invoke('updateTimer', {
          'action': 'updateTimer', // <-- Añadir acción
          'seconds': _remainingSeconds
        });
        _updateNotification('SOS Activo', 'Tiempo restante: ${(_remainingSeconds ~/ 60)}m ${(_remainingSeconds % 60)}s');

        if (_remainingSeconds <= 0) {
          print("BG_SERVICE: Tiempo de SOS finalizado.");
          stopTracking(byUser: true); // El tiempo se acabó, desactivar
        }
      });

      // 5. Iniciar temporizador de envío de ubicación (cada 15 segundos)
      _locationTimer?.cancel();
      _locationTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
        if (_alertId == null) {
          timer.cancel();
          return;
        }
        try {
          Position newPos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          await _apiService.addLocationUpdate(
            alertId: _alertId!,
            lat: newPos.latitude,
            lon: newPos.longitude,
          );
          print("BG_SERVICE: Ubicación actualizada enviada.");
        } catch (e) {
          print("BG_SERVICE: Error al enviar ubicación: $e");
          service.invoke('connectionLost', {'action': 'connectionLost'}); // <-- Añadir acción
        }
      });

    } catch (e) {
      print("BG_SERVICE: Error fatal al iniciar SOS: $e");
      service.invoke('sosFinished', {'action': 'sosFinished'}); // <-- Añadir acción
    }
  }

  Future<void> stopTracking({bool byUser = false}) async {
    print("BG_SERVICE: Deteniendo seguimiento... (Iniciado por usuario: $byUser)");
    
    // Detener temporizadores
    _countdownTimer?.cancel();
    _locationTimer?.cancel();
    _countdownTimer = null;
    _locationTimer = null;

    final int? alertIdToDeactivate = _alertId;
    _alertId = null; // Marcar como nulo inmediatamente
    _remainingSeconds = 0;

    if (byUser && alertIdToDeactivate != null) {
      try {
        await _apiService.deactivateSos(alertIdToDeactivate);
        print("BG_SERVICE: Alerta $alertIdToDeactivate desactivada en el backend.");
      } catch (e) {
        print("BG_SERVICE: Error al desactivar alerta $alertIdToDeactivate: $e");
      }
    }

    service.invoke('sosFinished', {'action': 'sosFinished'}); // <-- Añadir acción
    service.stopSelf();
  }

  void _updateNotification(String title, String body) {
    FlutterLocalNotificationsPlugin().show(
      NotificationService.SOS_NOTIFICATION_ID,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationService.SOS_CHANNEL_ID,
          'Alertas SOS',
          channelDescription: 'Notificaciones para el estado de la alerta SOS.',
          importance: Importance.high,
          priority: Priority.high,
          ongoing: true,
          autoCancel: false,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}

// --- FUNCIÓN DE INICIALIZACIÓN (para main.dart) ---
Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  // --- CORRECCIÓN ---
  // El canal SOS_CHANNEL_ID ahora se crea en NotificationService.initialize()
  // No es necesario crearlo aquí.
  // --- FIN CORRECCIÓN ---

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: false,
      notificationChannelId: NotificationService.SOS_CHANNEL_ID,
      initialNotificationTitle: 'Servicio SOS listo',
      initialNotificationContent: 'Esperando activación.',
      foregroundServiceNotificationId: NotificationService.SOS_NOTIFICATION_ID,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
    ),
  );
}