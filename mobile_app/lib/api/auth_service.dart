import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/utils/api_constants.dart';

class AuthService {
  // Función para registrar un nuevo usuario
  Future<Map<String, dynamic>> register({
    required String nombre,
    String? alias,
    required String email,
    required String password,
    String? telefono,
  }) async {
    // Construimos la URL completa del endpoint
    final url = Uri.parse(ApiConstants.baseUrl + ApiConstants.registerEndpoint);

    try {
      // Creamos el cuerpo de la petición con los datos del usuario
      final body = json.encode({
        'nombre': nombre,
        'alias': alias,
        'email': email,
        'password': password,
        'telefono': telefono, 
      });

      // Hacemos la petición POST a nuestra API
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // Decodificamos la respuesta JSON del servidor
      final responseData = json.decode(response.body);

      // Devolvemos un mapa con el estado y los datos de la respuesta
      return {
        'statusCode': response.statusCode,
        'data': responseData,
      };

    } catch (e) {
      // Si hay un error de conexión, devolvemos un mensaje genérico
      return {
        'statusCode': 500,
        'data': {'message': 'Error de conexión con el servidor. Inténtalo de nuevo.'}
      };
    }
  }
  // Función para iniciar sesión
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(ApiConstants.baseUrl + ApiConstants.loginEndpoint);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      final responseData = json.decode(response.body);
      return {
        'statusCode': response.statusCode,
        'data': responseData,
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'data': {'message': 'Error de conexión con el servidor.'}
      };
    }
  }
}