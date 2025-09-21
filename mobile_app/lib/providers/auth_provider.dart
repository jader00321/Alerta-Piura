import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthNotifier with ChangeNotifier {
  String? _token;
  String? _userRole;
  String? _userAlias;
  int? _userId;

  String? get token => _token;
  String? get userRole => _userRole;
  String? get userAlias => _userAlias;
  int? get userId => _userId;
  bool get isAuthenticated => _token != null;

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('authToken');
    final rememberMe = prefs.getBool('rememberMe') ?? false;

    if (savedToken != null && rememberMe && !JwtDecoder.isExpired(savedToken)) {
      _setAuthData(savedToken);
    } else {
      await logout(); // Clear everything if not remembered or token is invalid
    }
    notifyListeners();
  }

  Future<void> login(String token, bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    await prefs.setBool('rememberMe', rememberMe);
    _setAuthData(token);
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _clearAuthData();
    notifyListeners();
  }

  void _setAuthData(String token) {
    _token = token;
    final decodedToken = JwtDecoder.decode(token);
    _userRole = decodedToken['user']['rol'];
    _userAlias = decodedToken['user']['alias'] ?? decodedToken['user']['nombre'];
    _userId = decodedToken['user']['id'];
  }

  void _clearAuthData() {
    _token = null;
    _userRole = null;
    _userAlias = null;
    _userId = null;
  }
}