// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/services/socket_service.dart';
import 'package:mobile_app/api/auth_service.dart';

/// Gestiona el estado de autenticación del usuario en toda la aplicación.
///
/// Utiliza `ChangeNotifier` para notificar a los widgets (consumidores)
/// cuando el estado de autenticación cambia (ej. login, logout).
///
/// Almacena el token y los datos decodificados del usuario (ID, rol, alias, plan).
class AuthNotifier with ChangeNotifier {
  /// El token de autenticación JWT.
  ///
  /// Es `null` si el usuario no está autenticado.
  String? _token;

  /// El rol del usuario (ej. 'usuario', 'lider_vecinal', 'admin').
  String? _userRole;

  /// El alias (apodo) del usuario.
  String? _userAlias;

  /// El ID numérico único del usuario.
  int? _userId;

  /// El ID del plan de suscripción del usuario.
  ///
  /// Es `null` si el usuario no tiene un plan (no es premium).
  int? _planId;

  // --- Getters Públicos ---

  /// Retorna el token JWT actual, o `null` si no está autenticado.
  String? get token => _token;

  /// Retorna el rol del usuario, o `null` si no está autenticado.
  String? get userRole => _userRole;

  /// Retorna el alias del usuario, o `null` si no está autenticado.
  String? get userAlias => _userAlias;

  /// Retorna el ID del usuario, o `null` si no está autenticado.
  int? get userId => _userId;

  // --- Getters Computados (Booleanos) ---

  /// Retorna `true` si el usuario está autenticado (existe un token).
  bool get isAuthenticated => _token != null;

  /// Retorna `true` si el usuario tiene un plan de suscripción activo.
  bool get isPremium => _planId != null;

  /// Retorna `true` si el rol del usuario es 'lider_vecinal'.
  bool get isLider => _userRole == 'lider_vecinal';

  /// Retorna `true` si el rol del usuario es 'admin'.
  bool get isAdmin => _userRole == 'admin';

  /// Intenta renovar el token de sesión usando el [AuthService].
  ///
  /// Si la renovación es exitosa, actualiza el estado con [login].
  /// Si falla (ej. token expirado), fuerza un [logout].
  Future<void> refreshUserStatus() async {
    final newToken = await AuthService().refreshToken();
    if (newToken != null) {
      await login(newToken);
    } else {
      await logout();
    }
  }

  /// Verifica el estado de autenticación al iniciar la aplicación.
  ///
  /// Busca un token en [SharedPreferences]. Si encuentra uno válido
  /// y no expirado, configura los datos del usuario.
  /// Si no, fuerza un [logout].
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

  /// Inicia sesión en el estado de la aplicación.
  ///
  /// Guarda el [token] en [SharedPreferences], decodifica sus datos
  /// con [_setAuthData], y autentica la conexión del socket.
  /// Finalmente, notifica a los oyentes.
  Future<void> login(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    _setAuthData(token);
    _authenticateSocket(token);
    notifyListeners();
  }

  /// Cierra la sesión del usuario.
  ///
  /// Elimina el token de [SharedPreferences], limpia los datos de
  /// estado locales y desconecta el socket.
  /// Finalmente, notifica a los oyentes.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    _clearAuthData();
    SocketService().disconnect();
    notifyListeners();
  }

  // --- Métodos Privados ---

  /// Autentica la conexión del WebSocket pasando el [token].
  ///
  /// Obtiene la instancia de [SocketService] y llama a `connect`,
  /// que ahora maneja la lógica de autenticación al conectarse.
  void _authenticateSocket(String token) {
    final socketService = SocketService();
    // 1. Pasar el token directamente al conectar
    socketService.connect(token);
  }

  /// Decodifica un [token] JWT y almacena sus datos en las variables de estado.
  ///
  /// Extrae `userId`, `rol`, `alias` y `planId` del payload del token.
  /// Si la decodificación falla, limpia los datos.
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

  /// Limpia todas las variables de estado de autenticación,
  /// estableciéndolas en `null`.
  void _clearAuthData() {
    _token = null;
    _userId = null;
    _userRole = null;
    _userAlias = null;
    _planId = null;
  }
}