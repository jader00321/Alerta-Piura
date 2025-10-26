// lib/services/background_service.dart
import 'dart:async';
//import 'dart:ui';
//import 'package:flutter/material.dart';
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

  // --- NUEVO: Responder a la consulta de estado ---
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
  bool _isActive = false; // Estado interno para saber si está corriendo

  SosTrackingService(this.service) {
    _init();
  }

  void _init() async {
    // ... (inicialización de notificaciones sin cambios) ...
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
  }

  // --- NUEVO: Enviar estado actual a la UI ---
  void sendStatusToUI() {
    service.invoke('currentSosStatus', {
      'action': 'currentSosStatus', // Importante incluir la acción
      'isActive': _isActive,
      'alertId': _alertId,
      'seconds': _remainingSeconds,
    });
    print(
        "BG_SERVICE: Estado actual enviado a UI -> isActive: $_isActive, alertId: $_alertId, remaining: $_remainingSeconds");
  }

  Future<void> startTracking({
    required int durationInSeconds,
    Map<String, dynamic>? emergencyContact,
  }) async {
    if (_isActive) {
      print("BG_SERVICE: Intento de iniciar SOS cuando ya está activo.");
      return; // Ya está activo, no hacer nada
    }

    print("BG_SERVICE: Iniciando seguimiento SOS...");
    _remainingSeconds = durationInSeconds;
    _isActive = true; // Marcar como activo internamente

    try {
      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _alertId = await _apiService.activateSos(
        lat: pos.latitude,
        lon: pos.longitude,
        durationInSeconds: durationInSeconds,
        emergencyContact: emergencyContact?.cast<String, String?>(),
      );

      if (_alertId == null) {
        print("BG_SERVICE: Error al activar SOS en el backend.");
        _isActive = false; // Falló la activación
        service.invoke('sosFinished', {
          'action': 'sosFinished',
          'error': 'Failed to activate on backend'
        });
        return;
      }

      print("BG_SERVICE: Alerta activada con ID: $_alertId");
      service.invoke('sosStarted', {
        'action': 'sosStarted',
        'alertId': _alertId,
        'seconds': _remainingSeconds,
      });
      _updateNotification('SOS Activo', 'Enviando ubicación...');

      // --- Timer de cuenta regresiva ---
      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!_isActive) {
          // Doble chequeo por si se detuvo mientras esperaba el tick
          timer.cancel();
          return;
        }
        _remainingSeconds--;
        print(
            "BG_SERVICE: Tick Countdown - Remaining: $_remainingSeconds"); // LOGGING

        service.invoke('updateTimer',
            {'action': 'updateTimer', 'seconds': _remainingSeconds});
        _updateNotification('SOS Activo',
            'Tiempo restante: ${(_remainingSeconds ~/ 60)}m ${(_remainingSeconds % 60)}s');

        if (_remainingSeconds <= 0) {
          print("BG_SERVICE: Tiempo de SOS finalizado.");
          stopTracking(byUser: true); // Desactivar porque se acabó el tiempo
        }
      });

      // --- Timer de envío de ubicación ---
      _locationTimer?.cancel();
      _locationTimer =
          Timer.periodic(const Duration(seconds: 15), (timer) async {
        if (!_isActive || _alertId == null) {
          // Usar _isActive y verificar _alertId
          timer.cancel();
          return;
        }
        try {
          Position newPos = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          bool success = await _apiService.addLocationUpdate(
            alertId: _alertId!,
            lat: newPos.latitude,
            lon: newPos.longitude,
          );
          print(
              "BG_SERVICE: Ubicación actualizada enviada (Success: $success).");
        } catch (e) {
          print("BG_SERVICE: Error al enviar ubicación: $e");
          service.invoke('connectionLost', {'action': 'connectionLost'});
        }
      });
    } catch (e) {
      print("BG_SERVICE: Error fatal al iniciar SOS: $e");
      _isActive = false; // Marcar como inactivo si falla
      service.invoke(
          'sosFinished', {'action': 'sosFinished', 'error': e.toString()});
    }
  }

  Future<void> stopTracking({bool byUser = false}) async {
    if (!_isActive) {
      print("BG_SERVICE: Intento de detener SOS cuando no está activo.");
      return; // No estaba activo, no hacer nada
    }

    print(
        "BG_SERVICE: Deteniendo seguimiento... (Iniciado por usuario: $byUser)");
    _isActive = false; // Marcar como inactivo

    // Detener temporizadores
    _countdownTimer?.cancel();
    _locationTimer?.cancel();
    _countdownTimer = null;
    _locationTimer = null;

    final int? alertIdToDeactivate = _alertId;
    _alertId = null;
    _remainingSeconds = 0;

    // Notificar al backend SOLO si fue detenido por el usuario O por tiempo agotado
    if (byUser && alertIdToDeactivate != null) {
      try {
        await _apiService.deactivateSos(alertIdToDeactivate);
        print(
            "BG_SERVICE: Alerta $alertIdToDeactivate desactivada en el backend.");
      } catch (e) {
        print(
            "BG_SERVICE: Error al desactivar alerta $alertIdToDeactivate: $e");
      }
    }

    // Notificar a la UI que terminó y detener el servicio
    service.invoke('sosFinished', {'action': 'sosFinished'});
    service.stopSelf();
    print("BG_SERVICE: Servicio detenido.");
  }

  void _updateNotification(String title, String body) {
    // ... (lógica de notificación sin cambios) ...
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
            presentAlert: true, presentBadge: true, presentSound: true),
      ),
    );
  }
}

// --- FUNCIÓN DE INICIALIZACIÓN (sin cambios) ---
Future<void> initializeBackgroundService() async {
  // ... (código existente sin cambios) ...
  final service = FlutterBackgroundService();
  // El canal SOS_CHANNEL_ID se crea en NotificationService.initialize()
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
