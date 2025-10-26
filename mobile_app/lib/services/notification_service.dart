// lib/services/notification_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // --- Implementación como Singleton ---
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // IDs estáticos para que el BackgroundService pueda usarlos
  static const String SOS_CHANNEL_ID = 'sos_service_channel';
  static const int SOS_NOTIFICATION_ID = 888;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  GlobalKey<NavigatorState>? _navigatorKey;

  // --- Canales de Notificación para Android ---
  static const AndroidNotificationChannel _generalChannel =
      AndroidNotificationChannel(
    'general_channel',
    'Alertas Generales',
    description: 'Notificaciones y anuncios del sistema.',
    importance: Importance.max,
  );

  static const AndroidNotificationChannel _reportChannel =
      AndroidNotificationChannel(
    'report_updates_channel',
    'Actualizaciones de Reportes',
    description:
        'Notificaciones sobre el estado de tus reportes y comentarios.',
    importance: Importance.high,
  );

  // --- CORRECCIÓN: Canal de SOS añadido ---
  static const AndroidNotificationChannel _sosChannel =
      AndroidNotificationChannel(
    SOS_CHANNEL_ID,
    'Alertas SOS',
    description: 'Notificaciones para el estado de la alerta SOS.',
    importance: Importance.high, // Importancia alta para SOS
  );

  /// Inicializa el servicio. Debe ser llamado en main.dart
  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;

    // --- CORRECCIÓN: Crear todos los canales aquí ---
    final androidPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(_generalChannel);
    await androidPlugin?.createNotificationChannel(_reportChannel);
    await androidPlugin?.createNotificationChannel(_sosChannel); // <-- AÑADIDO

    // Configuración para Android y iOS
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Callback que se ejecuta cuando el usuario toca una notificación.
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        final Map<String, dynamic> payload = json.decode(response.payload!);
        final String? type = payload['type'];
        final dynamic id = payload['id'];

        if (_navigatorKey?.currentState != null) {
          if (type == 'report_detail' && id != null) {
            _navigatorKey!.currentState!.pushNamed('/reporte_detalle',
                arguments: int.parse(id.toString()));
          } else if (type == 'alerts_screen') {
            _navigatorKey!.currentState!.pushNamed('/alertas');
          }
        }
      } catch (e) {
        print('Error al procesar el payload de la notificación: $e');
      }
    }
  }

  /// Muestra una notificación local en el dispositivo.
  Future<void> showNotification(String title, String body,
      {String? payload}) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _reportChannel.id, // Usamos el canal de reportes por defecto
      _reportChannel.name,
      channelDescription: _reportChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000), // ID único
      title,
      body,
      platformChannelSpecifics,
      payload: payload, // Adjuntamos el payload
    );
  }
}
