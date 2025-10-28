import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestiona la autenticación de usuarios con la API.
///
/// Esta clase se encarga de los procesos de registro (`register`),
/// inicio de sesión (`login`) y renovación de tokens (`refreshToken`).
class AuthService {
  /// Registra un nuevo usuario en el sistema.
  ///
  /// Envía los datos del formulario al endpoint `/api/auth/register`.
  ///
  /// - [nombre]: El nombre completo del usuario.
  /// - [alias]: (Opcional) Un apodo para el usuario.
  /// - [email]: El correo electrónico, que se usará para el login.
  /// - [password]: La contraseña en texto plano.
  /// - [telefono]: (Opcional) El número de teléfono del usuario.
  ///
  /// Retorna un [Map] que contiene:
  /// - `statusCode`: El código HTTP de la respuesta.
  /// - `data`: El cuerpo de la respuesta (JSON decodificado).
  ///
  /// En caso de un error de conexión (timeout, sin internet),
  /// retorna un `statusCode` 500 y un mensaje de error genérico.
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
      // Atrapa errores de conexión (ej. sin internet, timeout)
      return {
        'statusCode': 500,
        'data': {'message': 'Error de conexión. Por favor, revisa tu internet.'}
      };
    }
  }

  /// Autentica a un usuario y devuelve un token de sesión.
  ///
  /// Envía [email] y [password] al endpoint `/api/auth/login`.
  ///
  /// Retorna un [Map] que contiene:
  /// - `statusCode`: El código HTTP de la respuesta.
  /// - `data`: El cuerpo de la respuesta (JSON decodificado),
  ///   que debería incluir el token de autenticación si es exitoso.
  ///
  /// En caso de un error de conexión (timeout, sin internet),
  /// retorna un `statusCode` 500 y un mensaje de error genérico.
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
      // Atrapa errores de conexión (ej. sin internet, timeout)
      return {
        'statusCode': 500,
        'data': {'message': 'Error de conexión. Por favor, revisa tu internet.'}
      };
    }
  }

  /// Intenta renovar el token de autenticación usando el token actual.
  ///
  /// Obtiene el 'authToken' guardado en [SharedPreferences] y lo envía
  /// al endpoint `/api/auth/refresh-token`.
  ///
  /// Retorna el nuevo token (`String`) si la renovación es exitosa (código 200).
  ///
  /// Retorna [null] en cualquiera de estos casos:
  /// 1. No hay un token guardado localmente.
  /// 2. El token actual ha expirado (la API devuelve 401).
  /// 3. Ocurre un error de conexión (timeout, sin internet).
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