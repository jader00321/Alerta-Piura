import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // CORREGIDO: Renombrar constantes a lowerCamelCase
  static const String sosChannelId = 'sos_service_channel';
  static const int sosNotificationId = 888;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  GlobalKey<NavigatorState>? _navigatorKey;

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

  static const AndroidNotificationChannel _sosChannel =
      AndroidNotificationChannel(
    sosChannelId,
    'Alertas SOS',
    description: 'Notificaciones para el estado de la alerta SOS.',
    importance: Importance.high,
  );

  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;

    final androidPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(_generalChannel);
    await androidPlugin?.createNotificationChannel(_reportChannel);
    await androidPlugin?.createNotificationChannel(_sosChannel);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

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
        debugPrint('Error al procesar el payload de la notificación: $e');
      }
    }
  }

  Future<void> showNotification(String title, String body,
      {String? payload}) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _reportChannel.id,
      _reportChannel.name,
      channelDescription: _reportChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}
