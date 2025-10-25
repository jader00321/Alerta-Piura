// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/services/socket_service.dart';
import 'package:mobile_app/api/auth_service.dart';

class AuthNotifier with ChangeNotifier {
  String? _token;
  String? _userRole;
  String? _userAlias;
  int? _userId;
  int? _planId;

  String? get token => _token;
  String? get userRole => _userRole;
  String? get userAlias => _userAlias;
  int? get userId => _userId;

  bool get isAuthenticated => _token != null;
  bool get isPremium => _planId != null;
  bool get isLider => _userRole == 'lider_vecinal';
  bool get isAdmin => _userRole == 'admin';

  Future<void> refreshUserStatus() async {
    final newToken = await AuthService().refreshToken();
    if (newToken != null) {
      await login(newToken);
    } else {
      await logout();
    }
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('authToken');

    if (savedToken != null && !JwtDecoder.isExpired(savedToken)) {
      _setAuthData(savedToken);
      _authenticateSocket(savedToken);
    } else {
      await logout();
    }
    notifyListeners();
  }

  Future<void> login(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    _setAuthData(token);
    _authenticateSocket(token);
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    _clearAuthData();
    SocketService().disconnect();
    notifyListeners();
  }

  // --- FUNCIÓN CORREGIDA ---
  void _authenticateSocket(String token) {
    final socketService = SocketService();
    // 1. Pasar el token directamente al conectar
    socketService.connect(token);
    
    // 2. Esta línea ya no es necesaria, la autenticación
    //    se maneja en el momento de la conexión.
    // socketService.emit('authenticate', {'token': token});
  }
  // --- FIN CORRECCIÓN ---

  void _setAuthData(String token) {
    _token = token;
    try {
      final decodedToken = JwtDecoder.decode(token);
      final userPayload = decodedToken['user'];

      _userId = userPayload['userId'];
      _userRole = userPayload['rol'];
      _userAlias = userPayload['alias'];
      _planId = userPayload['planId'];
    } catch (e) {
      _clearAuthData();
    }
  }

  void _clearAuthData() {
    _token = null;
    _userId = null;
    _userRole = null;
    _userAlias = null;
    _planId = null;
  }
}