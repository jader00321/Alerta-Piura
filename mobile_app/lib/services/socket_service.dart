// lib/services/socket_service.dart
import 'dart:async'; // <-- IMPORTAR ASYNC
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:mobile_app/utils/api_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_app/services/notification_service.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;

  // --- NUEVO: StreamController para el evento de detención de SOS ---
  final StreamController<Map<String, dynamic>> _stopSosController =
      StreamController.broadcast();

  // --- NUEVO: Stream público para que otros escuchen ---
  Stream<Map<String, dynamic>> get onStopSos => _stopSosController.stream;

  void connect(String token) {
    // <-- MODIFICADO: Aceptar token
    if (_socket?.connected ?? false) {
      debugPrint('Socket ya conectado.');
      return;
    }

    // --- MODIFICADO: Enviar token en la query para autenticación inmediata ---
    _socket = IO.io(ApiConstants.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true, // Conectar automáticamente
      'query': {'token': token} // Enviar token aquí
    });

    _setupListeners();
    // No necesitamos 'authenticate' manual, pero la conexión sí
    _socket!.connect();
  }

  void _setupListeners() {
    _socket?.onConnect((_) {
      debugPrint('Socket conectado: ${_socket!.id}');
    });

    _socket?.on('authenticated', (_) {
      debugPrint('Socket autenticado exitosamente!');
    });

    _socket?.on('unauthorized', (data) {
      debugPrint('Fallo en la autenticación del socket: ${data['message']}');
    });

    _socket?.onDisconnect((_) {
      debugPrint('Socket desconectado.');
    });

    _socket?.onError((error) {
      debugPrint('Error de Socket: $error');
    });

    // --- LISTENER DE NOTIFICACIONES (EXISTENTE) ---
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

    // --- NUEVO: LISTENER PARA DETENCIÓN FORZADA DE SOS ---
    _socket?.on('stopSos', (data) {
      debugPrint('Evento stopSos recibido del servidor: $data');
      if (data is Map<String, dynamic>) {
        // Añadir el evento al stream para que los listeners (main.dart) reaccionen
        _stopSosController.add(data);
      }
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  // --- CERRAR STREAM ---
  void dispose() {
    _stopSosController.close();
  }

  // --- MÉTODOS EMIT, ON, OFF (EXISTENTES, PERO AHORA OBSOLETOS SI USAS EL TOKEN EN LA CONEXIÓN) ---
  // El 'emit' de 'authenticate' ya no es necesario si se usa la query
  void emit(String event, dynamic data) {
    if (_socket?.connected ?? false) {
      _socket!.emit(event, data);
    } else {
      debugPrint('No se puede emitir evento, socket no conectado.');
    }
  }

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }
}
