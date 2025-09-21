import 'dart:io';

// Esta clase nos ayudará a definir la URL base de nuestra API.
class ApiConstants {
  // Verificamos si la plataforma es Android para usar la IP especial.
  // Para iOS y otras plataformas, 'localhost' funciona correctamente.
  static String baseUrl = Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';
  
  // Endpoints específicos de nuestra API
  static String registerEndpoint = '/api/auth/register';
  static String loginEndpoint = '/api/auth/login';
}