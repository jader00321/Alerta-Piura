import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  /// Registra un nuevo usuario en el sistema.
  Future<Map<String, dynamic>> register({
    required String nombre,
    String? alias,
    required String email,
    required String password,
    String? telefono,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': nombre,
          'alias': alias,
          'email': email,
          'password': password,
          'telefono': telefono,
        }),
      );

      return {
        'statusCode': response.statusCode,
        'data': json.decode(response.body),
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'data': {'message': 'Error de conexión. Por favor, revisa tu internet.'}
      };
    }
  }

  /// Autentica a un usuario y devuelve un token de sesión.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      return {
        'statusCode': response.statusCode,
        'data': json.decode(response.body),
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'data': {'message': 'Error de conexión. Por favor, revisa tu internet.'}
      };
    }
  }

  Future<String?> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final currentToken = prefs.getString('authToken');
    if (currentToken == null) return null;

    final url = Uri.parse('${ApiConstants.baseUrl}/api/auth/refresh-token');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $currentToken'},
      );
      if (response.statusCode == 200) {
        // El backend nos devuelve un token fresco.
        return json.decode(response.body)['token'];
      }
      // Si el token es inválido (ej. expiró), el backend devolverá 401.
      return null;
    } catch (e) {
      // Error de conexión
      return null;
    }
  }
}
