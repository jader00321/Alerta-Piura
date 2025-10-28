import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// {@template notification_service}
/// Servicio Singleton para gestionar las notificaciones locales.
///
/// Maneja la inicialización, la creación de canales de Android,
/// la visualización de notificaciones y la navegación cuando
/// el usuario toca una notificación.
/// {@endtemplate}
class NotificationService {
  /// Instancia Singleton del servicio.
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// ID del canal de notificación para el servicio SOS.
  static const String sosChannelId = 'sos_service_channel';
  /// ID único para la notificación persistente del SOS.
  static const int sosNotificationId = 888;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  /// Clave global del [Navigator] para permitir la navegación desde
  /// el callback [onDidReceiveNotificationResponse].
  GlobalKey<NavigatorState>? _navigatorKey;

  /// Canal para alertas generales del sistema.
  static const AndroidNotificationChannel _generalChannel =
      AndroidNotificationChannel(
    'general_channel',
    'Alertas Generales',
    description: 'Notificaciones y anuncios del sistema.',
    importance: Importance.max,
  );

  /// Canal para actualizaciones de reportes y comentarios.
  static const AndroidNotificationChannel _reportChannel =
      AndroidNotificationChannel(
    'report_updates_channel',
    'Actualizaciones de Reportes',
    description: 'Notificaciones sobre el estado de tus reportes y comentarios.',
    importance: Importance.high,
  );

  /// Canal dedicado a la notificación persistente del SOS.
  static const AndroidNotificationChannel _sosChannel = AndroidNotificationChannel(
    sosChannelId,
    'Alertas SOS',
    description: 'Notificaciones para el estado de la alerta SOS.',
    importance: Importance.high,
  );

  /// Inicializa el servicio de notificaciones.
  ///
  /// Debe llamarse en `main.dart`.
  /// Crea los canales de Android y configura los settings de inicialización
  /// para Android e iOS, incluyendo el callback [onDidReceiveNotificationResponse].
  ///
  /// [navigatorKey]: La [GlobalKey<NavigatorState>] de [MaterialApp].
  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;

    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    /// Crea los tres canales de notificación en Android.
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

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      /// Define el callback que se ejecuta al tocar la notificación.
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Callback que maneja el tap en una notificación.
  ///
  /// Parsea el [response.payload] (JSON) para determinar el `type` y `id`
  /// de la navegación, y utiliza el [_navigatorKey] para navegar a la
  /// pantalla correspondiente (ej. `/reporte_detalle`).
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        final Map<String, dynamic> payload = json.decode(response.payload!);
        final String? type = payload['type'];
        final dynamic id = payload['id'];

        if (_navigatorKey?.currentState != null) {
          if (type == 'report_detail' && id != null) {
            _navigatorKey!.currentState!
                .pushNamed('/reporte_detalle', arguments: int.parse(id.toString()));
          } else if (type == 'alerts_screen') {
            _navigatorKey!.currentState!.pushNamed('/alertas');
          }
          // ... (se pueden añadir más tipos de navegación aquí)
        }
      } catch (e) {
        debugPrint('Error al procesar el payload de la notificación: $e');
      }
    }
  }

  /// Muestra una notificación local estándar (no-SOS).
  ///
  /// Utiliza el canal [_reportChannel] por defecto.
  Future<void> showNotification(String title, String body, {String? payload}) async {
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
      DateTime.now().millisecondsSinceEpoch.remainder(100000), // ID único
      title,
      body,
      platformChannelSpecifics,
      payload: payload, // El JSON string para la navegación.
    );
  }
}