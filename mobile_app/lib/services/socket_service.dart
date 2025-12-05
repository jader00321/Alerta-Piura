import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:mobile_app/utils/api_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_app/services/notification_service.dart';

/// {@template socket_service}
/// Servicio Singleton para gestionar la conexión WebSocket (Socket.IO).
///
/// Maneja la conexión, autenticación, y la escucha de eventos en tiempo real
/// desde el servidor.
/// {@endtemplate}
class SocketService {
  /// Instancia Singleton del servicio.
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  /// La instancia del socket de Socket.IO.
  io.Socket? _socket;

  /// StreamController para el evento 'stopSos' (cuando un admin detiene el SOS).
  final StreamController<Map<String, dynamic>> _stopSosController =
      StreamController.broadcast();
  
  /// Stream público para que la UI escuche el evento 'stopSos'.
  Stream<Map<String, dynamic>> get onStopSos => _stopSosController.stream;

  /// Inicializa la conexión con el servidor.
  ///
  /// [token]: El JWT del usuario para autenticarse en el handshake.
  void connect(String token) {
    if (_socket != null && _socket!.connected) return;

    _socket = io.io(ApiConstants.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'token': token}, // Enviar token en el handshake
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint('SocketService: Conectado al servidor.');
    });

    _socket!.onDisconnect((_) {
      debugPrint('SocketService: Desconectado del servidor.');
    });

    _socket!.on('notification', (data) {
      if (data is Map<String, dynamic>) {
        final title = data['title'] as String?;
        final body = data['body'] as String?;
        final payload = data['payload'] as String?;

        if (title != null && body != null) {
          NotificationService().showNotification(title, body, payload: payload);
        }
      }
    });

    _socket!.on('stopSos', (data) {
      debugPrint('Evento stopSos recibido del servidor: $data');
      if (data is Map<String, dynamic>) {
        _stopSosController.add(data);
      }
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

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
  /// 
  /// [handler] debe ser una función que reciba datos dinámicos.
  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  /// Elimina un listener para un evento.
  ///
  /// **CORRECCIÓN:** Ahora acepta un segundo parámetro opcional [handler].
  /// Si se pasa [handler], solo elimina esa función específica.
  /// Si no se pasa, elimina todos los listeners del evento.
  void off(String event, [dynamic Function(dynamic)? handler]) {
    _socket?.off(event, handler);
  }
}