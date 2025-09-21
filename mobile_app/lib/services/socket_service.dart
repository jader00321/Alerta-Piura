import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:mobile_app/utils/api_constants.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;

  void connect() {
    if (_socket?.connected ?? false) return;
    _socket = IO.io(ApiConstants.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }
}