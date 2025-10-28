import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:mobile_app/utils/api_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_app/services/notification_service.dart';

/// {@template socket_service}
/// Servicio Singleton para gestionar la conexión WebSocket (Socket.IO).
///
/// Maneja la conexión, autenticación, y la escucha de eventos en tiempo real
/// desde el servidor. Proporciona métodos `emit` para enviar eventos
/// y `Streams` públicos para que la UI reaccione a eventos específicos
/// (como [onStopSos]).
/// {@endtemplate}
class SocketService {
  /// Instancia Singleton del servicio.
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  /// La instancia del socket de Socket.IO.
  io.Socket? _socket;

  /// StreamController para el evento 'stopSos' (cuando un admin detiene el SOS).
  /// Es broadcast para permitir múltiples listeners (ej. en `main.dart`).
  final StreamController<Map<String, dynamic>> _stopSosController =
      StreamController.broadcast();
  
  /// Stream público para que la UI (u otros servicios) escuche el evento 'stopSos'.
  Stream<Map<String, dynamic>> get onStopSos => _stopSosController.stream;

  /// {@template socket_service.connect}
  /// Inicia la conexión con el servidor Socket.IO.
  ///
  /// Envía automáticamente el [token] de autenticación en la query
  /// de la conexión para una autenticación inmediata.
  /// Si ya existe una conexión, no hace nada.
  ///
  /// [token]: El token JWT del usuario autenticado.
  /// {@endtemplate}
  void connect(String token) {
    if (_socket?.connected ?? false) {
      debugPrint('Socket ya conectado.');
      return;
    }

    /// Configura el socket para conectarse a la [ApiConstants.baseUrl]
    /// enviando el token en la query de autenticación.
    _socket = io.io(ApiConstants.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'query': {'token': token} // Autenticación inmediata
    });

    _setupListeners();
    _socket!.connect();
  }

  /// Configura todos los listeners para los eventos entrantes del servidor.
  void _setupListeners() {
    _socket?.onConnect((_) {
      debugPrint('Socket conectado: ${_socket!.id}');
    });

    _socket?.on('authenticated', (_) {
      debugPrint('Socket autenticado exitosamente!');
    });

    _socket?.on('unauthorized', (data) {
      debugPrint('Fallo en la autenticación del socket: ${data['message']}');
      // Podría implementarse un reintento de logout/login aquí si es necesario.
    });

    _socket?.onDisconnect((_) {
      debugPrint('Socket desconectado.');
    });

    _socket?.onError((error) {
      debugPrint('Error de Socket: $error');
    });

    /// Listener para notificaciones push en tiempo real.
    /// Recibe la data y la pasa a [NotificationService] para mostrarla.
    _socket?.on('notification', (data) {
      debugPrint('Notificación recibida vía socket: $data');
      if (data is Map<String, dynamic>) {
        final title = data['title'] as String?;
        final body = data['body'] as String?;
        final payload = data['payload'] as String?;

        if (title != null && body != null) {
          NotificationService().showNotification(title, body, payload: payload);
        }
      }
    });

    /// Listener para el evento de detención forzada de SOS (enviado por un admin).
    _socket?.on('stopSos', (data) {
      debugPrint('Evento stopSos recibido del servidor: $data');
      if (data is Map<String, dynamic>) {
        /// Añade el evento al stream [onStopSos] para que `main.dart`
        /// pueda reaccionar e invocar al [BackgroundService].
        _stopSosController.add(data);
      }
    });
  }

  /// Desconecta manualmente el socket del servidor.
  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  /// Libera los recursos (cierra los [StreamController]s).
  void dispose() {
    _stopSosController.close();
  }

  /// Emite un evento [event] con [data] al servidor.
  void emit(String event, dynamic data) {
    if (_socket?.connected ?? false) {
      _socket!.emit(event, data);
    } else {
      debugPrint('No se puede emitir evento, socket no conectado.');
    }
  }

  /// Registra un [handler] para escuchar un [event] del servidor.
  /// (Usado por [ChatScreen] para `receive-message`).
  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  /// Deja de escuchar un [event] específico del servidor.
  void off(String event) {
    _socket?.off(event);
  }
}