import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_app/api/sos_service.dart';
import 'package:mobile_app/services/notification_service.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  final SosTrackingService trackingService = SosTrackingService(service);

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

  service.on('getSosStatus').listen((payload) {
    trackingService.sendStatusToUI();
  });
}

class SosTrackingService {
  final ServiceInstance service;
  final SosService _apiService = SosService();

  Timer? _locationTimer;
  Timer? _countdownTimer;
  int? _alertId;
  int _remainingSeconds = 0;
  bool _isActive = false;

  SosTrackingService(this.service) {
    _init();
  }

  void _init() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
  }

  void sendStatusToUI() {
    service.invoke('currentSosStatus', {
      'action': 'currentSosStatus',
      'isActive': _isActive,
      'alertId': _alertId,
      'seconds': _remainingSeconds,
    });
    debugPrint(
        "BG_SERVICE: Estado actual enviado a UI -> isActive: $_isActive, alertId: $_alertId, remaining: $_remainingSeconds");
  }

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
      Position pos = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high));
      _alertId = await _apiService.activateSos(
        lat: pos.latitude,
        lon: pos.longitude,
        durationInSeconds: durationInSeconds,
        emergencyContact: emergencyContact?.cast<String, String?>(),
      );

      if (_alertId == null) {
        debugPrint("BG_SERVICE: Error al activar SOS en el backend.");
        _isActive = false;
        service.invoke('sosFinished', {
          'action': 'sosFinished',
          'error': 'Failed to activate on backend'
        });
        return;
      }

      debugPrint("BG_SERVICE: Alerta activada con ID: $_alertId");
      service.invoke('sosStarted', {
        'action': 'sosStarted',
        'alertId': _alertId,
        'seconds': _remainingSeconds,
      });
      _updateNotification('SOS Activo', 'Enviando ubicación...');

      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!_isActive) {
          timer.cancel();
          return;
        }
        _remainingSeconds--;
        debugPrint(
            "BG_SERVICE: Tick Countdown - Remaining: $_remainingSeconds");

        service.invoke('updateTimer',
            {'action': 'updateTimer', 'seconds': _remainingSeconds});
        _updateNotification('SOS Activo',
            'Tiempo restante: ${(_remainingSeconds ~/ 60)}m ${(_remainingSeconds % 60)}s');

        if (_remainingSeconds <= 0) {
          debugPrint("BG_SERVICE: Tiempo de SOS finalizado.");
          stopTracking(byUser: true);
        }
      });

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
          debugPrint(
              "BG_SERVICE: Ubicación actualizada enviada (Success: $success).");
        } catch (e) {
          debugPrint("BG_SERVICE: Error al enviar ubicación: $e");
          service.invoke('connectionLost', {'action': 'connectionLost'});
        }
      });
    } catch (e) {
      debugPrint("BG_SERVICE: Error fatal al iniciar SOS: $e");
      _isActive = false;
      service.invoke(
          'sosFinished', {'action': 'sosFinished', 'error': e.toString()});
    }
  }

  Future<void> stopTracking({bool byUser = false}) async {
    if (!_isActive) {
      debugPrint("BG_SERVICE: Intento de detener SOS cuando no está activo.");
      return;
    }

    debugPrint(
        "BG_SERVICE: Deteniendo seguimiento... (Iniciado por usuario: $byUser)");
    _isActive = false;

    _countdownTimer?.cancel();
    _locationTimer?.cancel();
    _countdownTimer = null;
    _locationTimer = null;

    final int? alertIdToDeactivate = _alertId;
    _alertId = null;
    _remainingSeconds = 0;

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

    service.invoke('sosFinished', {'action': 'sosFinished'});
    service.stopSelf();
    debugPrint("BG_SERVICE: Servicio detenido.");
  }

  void _updateNotification(String title, String body) {
    FlutterLocalNotificationsPlugin().show(
      NotificationService.sosNotificationId,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationService.sosChannelId,
          'Alertas SOS',
          channelDescription: 'Notificaciones para el estado de la alerta SOS.',
          importance: Importance.high,
          priority: Priority.high,
          ongoing: true,
          autoCancel: false,
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
