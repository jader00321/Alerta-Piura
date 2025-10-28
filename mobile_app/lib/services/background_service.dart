import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_app/api/sos_service.dart';
import 'package:mobile_app/services/notification_service.dart';

/// {@template background_service_on_start}
/// Punto de entrada para el servicio en segundo plano.
///
/// Esta función se ejecuta en un Isolate separado cuando el servicio se inicia.
/// Configura los listeners para los eventos invocados desde la UI principal
/// (ej. 'startSosTracking', 'stopSosFromUI').
/// {@endtemplate}
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  /// Instancia única del manejador de lógica SOS dentro de este Isolate.
  final SosTrackingService trackingService = SosTrackingService(service);

  /// Listener para iniciar el seguimiento SOS.
  service.on('startSosTracking').listen((payload) {
    if (payload != null) {
      trackingService.startTracking(
        durationInSeconds: payload['durationInSeconds'],
        emergencyContact: payload['emergencyContact'],
      );
    }
  });

  /// Listener para detener el seguimiento desde la UI (botón del usuario).
  service.on('stopSosFromUI').listen((payload) {
    trackingService.stopTracking(byUser: true);
  });

  /// Listener para detener el seguimiento forzosamente desde el servidor (vía Socket).
  service.on('serverForceStop').listen((payload) {
    trackingService.stopTracking(byUser: false);
  });

  /// Listener para que la UI consulte el estado actual del SOS al reconectarse.
  service.on('getSosStatus').listen((payload) {
    trackingService.sendStatusToUI();
  });
}

/// {@template sos_tracking_service}
/// Clase que encapsula toda la lógica de estado del seguimiento SOS.
///
/// Maneja los temporizadores, la obtención de ubicación y la comunicación
/// con la API y la UI principal.
/// {@endtemplate}
class SosTrackingService {
  /// La instancia del servicio en segundo plano.
  final ServiceInstance service;
  /// Cliente de API para interactuar con los endpoints de SOS.
  final SosService _apiService = SosService();

  /// Temporizador para enviar actualizaciones de ubicación periódicas.
  Timer? _locationTimer;
  /// Temporizador para la cuenta regresiva de la duración del SOS.
  Timer? _countdownTimer;
  /// El ID de la alerta SOS activa, devuelto por el backend.
  int? _alertId;
  /// Segundos restantes de la alerta activa.
  int _remainingSeconds = 0;
  /// Flag de estado interno para saber si el SOS está activo.
  bool _isActive = false;

  /// {@macro sos_tracking_service}
  SosTrackingService(this.service) {
    _init();
  }

  /// Inicializa el plugin de notificaciones locales dentro del Isolate.
  void _init() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
  }

  /// Envía el estado actual del SOS (activo, ID, segundos) a la UI.
  /// Invocado por el listener 'getSosStatus'.
  void sendStatusToUI() {
    service.invoke('currentSosStatus', {
      'action': 'currentSosStatus',
      'isActive': _isActive,
      'alertId': _alertId,
      'seconds': _remainingSeconds,
    });
    debugPrint("BG_SERVICE: Estado actual enviado a UI -> isActive: $_isActive, alertId: $_alertId, remaining: $_remainingSeconds");
  }

  /// Inicia el proceso completo de seguimiento SOS.
  ///
  /// [durationInSeconds]: Duración total de la alerta.
  /// [emergencyContact]: Datos del contacto de emergencia.
  Future<void> startTracking({
    required int durationInSeconds,
    Map<String, dynamic>? emergencyContact,
  }) async {
    if (_isActive) {
      debugPrint("BG_SERVICE: Intento de iniciar SOS cuando ya está activo.");
      return;
    }

    debugPrint("BG_SERVICE: Iniciando seguimiento SOS...");
    _remainingSeconds = durationInSeconds;
    _isActive = true;

    try {
      /// 1. Obtener ubicación inicial.
      Position pos = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high));
      
      /// 2. Activar la alerta en el backend.
      _alertId = await _apiService.activateSos(
        lat: pos.latitude,
        lon: pos.longitude,
        durationInSeconds: durationInSeconds,
        emergencyContact: emergencyContact?.cast<String, String?>(),
      );

      if (_alertId == null) {
        throw Exception('Failed to activate on backend');
      }

      debugPrint("BG_SERVICE: Alerta activada con ID: $_alertId");
      /// 3. Notificar a la UI que el SOS comenzó.
      service.invoke('sosStarted', {
        'action': 'sosStarted',
        'alertId': _alertId,
        'seconds': _remainingSeconds,
      });
      _updateNotification('SOS Activo', 'Enviando ubicación...');

      /// 4. Iniciar temporizador de cuenta regresiva (cada 1 seg).
      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!_isActive) {
          timer.cancel();
          return;
        }
        _remainingSeconds--;
        debugPrint("BG_SERVICE: Tick Countdown - Remaining: $_remainingSeconds");

        /// 4a. Notificar a la UI del tiempo restante.
        service.invoke(
            'updateTimer', {'action': 'updateTimer', 'seconds': _remainingSeconds});
        _updateNotification('SOS Activo',
            'Tiempo restante: ${(_remainingSeconds ~/ 60)}m ${(_remainingSeconds % 60)}s');

        /// 4b. Detener si el tiempo se acaba.
        if (_remainingSeconds <= 0) {
          debugPrint("BG_SERVICE: Tiempo de SOS finalizado.");
          stopTracking(byUser: true); // Se detiene por tiempo agotado.
        }
      });

      /// 5. Iniciar temporizador de envío de ubicación (cada 15 seg).
      _locationTimer?.cancel();
      _locationTimer =
          Timer.periodic(const Duration(seconds: 15), (timer) async {
        if (!_isActive || _alertId == null) {
          timer.cancel();
          return;
        }
        try {
          Position newPos = await Geolocator.getCurrentPosition(
              locationSettings:
                  const LocationSettings(accuracy: LocationAccuracy.high));
          bool success = await _apiService.addLocationUpdate(
            alertId: _alertId!,
            lat: newPos.latitude,
            lon: newPos.longitude,
          );
          debugPrint("BG_SERVICE: Ubicación actualizada enviada (Success: $success).");
        } catch (e) {
          debugPrint("BG_SERVICE: Error al enviar ubicación: $e");
          /// 5a. Notificar a la UI si se pierde la conexión.
          service.invoke('connectionLost', {'action': 'connectionLost'});
        }
      });
    } catch (e) {
      debugPrint("BG_SERVICE: Error fatal al iniciar SOS: $e");
      _isActive = false;
      /// Notificar a la UI que el inicio falló.
      service
          .invoke('sosFinished', {'action': 'sosFinished', 'error': e.toString()});
    }
  }

  /// Detiene el servicio de seguimiento SOS.
  ///
  /// [byUser]: Si es `true`, notifica al backend que el usuario
  /// (o el temporizador) finalizó la alerta. Si es `false` (detenido por
  /// servidor), solo detiene los timers locales.
  Future<void> stopTracking({bool byUser = false}) async {
    if (!_isActive) {
      debugPrint("BG_SERVICE: Intento de detener SOS cuando no está activo.");
      return;
    }

    debugPrint("BG_SERVICE: Deteniendo seguimiento... (Iniciado por usuario: $byUser)");
    _isActive = false;

    _countdownTimer?.cancel();
    _locationTimer?.cancel();
    _countdownTimer = null;
    _locationTimer = null;

    final int? alertIdToDeactivate = _alertId;
    _alertId = null;
    _remainingSeconds = 0;

    /// 1. Notificar al backend (si aplica).
    if (byUser && alertIdToDeactivate != null) {
      try {
        await _apiService.deactivateSos(alertIdToDeactivate);
        debugPrint(
            "BG_SERVICE: Alerta $alertIdToDeactivate desactivada en el backend.");
      } catch (e) {
        debugPrint(
            "BG_SERVICE: Error al desactivar alerta $alertIdToDeactivate: $e");
      }
    }

    /// 2. Notificar a la UI que el SOS finalizó.
    service.invoke('sosFinished', {'action': 'sosFinished'});
    /// 3. Detener el servicio en segundo plano.
    service.stopSelf();
    debugPrint("BG_SERVICE: Servicio detenido.");
  }

  /// Actualiza la notificación persistente de Android.
  void _updateNotification(String title, String body) {
    FlutterLocalNotificationsPlugin().show(
      NotificationService.sosNotificationId,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationService.sosChannelId,
          'Alertas SOS',
          channelDescription:
              'Notificaciones para el estado de la alerta SOS.',
          importance: Importance.high,
          priority: Priority.high,
          ongoing: true, // Notificación persistente.
          autoCancel: false,
        ),
        iOS: DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true),
      ),
    );
  }
}

/// {@template initialize_background_service}
/// Configura e inicializa el [FlutterBackgroundService].
/// Define la configuración de Android (para modo 'foreground') y de iOS.
/// {@endtemplate}
Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      /// Punto de entrada del Isolate.
      onStart: onStart,
      /// Mantiene el servicio vivo.
      isForegroundMode: true,
      autoStart: false,
      notificationChannelId: NotificationService.sosChannelId,
      initialNotificationTitle: 'Servicio SOS listo',
      initialNotificationContent: 'Esperando activación.',
      foregroundServiceNotificationId: NotificationService.sosNotificationId,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart, // Punto de entrada para iOS en foreground.
    ),
  );
}