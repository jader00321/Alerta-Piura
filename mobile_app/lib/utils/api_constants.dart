import 'dart:io';

/// Define las constantes estáticas para conectarse a la API.
///
/// Esta clase centraliza las URLs base y los endpoints específicos,
/// facilitando la gestión de las direcciones de la API en un solo lugar.
class ApiConstants {
  /// La URL base del servidor backend.
  ///
  /// Utiliza una lógica de plataforma:
  /// - En **Android** (emulador), usa `http://10.0.2.2:3000`. Esta IP
  ///   especial es la forma en que el emulador de Android se
  ///   conecta al `localhost` de la máquina anfitriona.
  /// - En **iOS** (simulador) u otras plataformas (web, desktop),
  ///   usa `http://localhost:3000`.
  //static String baseUrl =
      //Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';

  // --- URL Alternativa para Pruebas en Red Local ---
  // Descomenta la siguiente línea y reemplaza la IP si necesitas
  // probar en un dispositivo físico conectado a la misma red WiFi
  // que tu computadora (ej. 192.168.1.10 es la IP de tu PC).
  static String baseUrl =
      Platform.isAndroid ? 'http://192.168.100.5:3000' : 'http://localhost:3000';
  // --------------------------------------------------

  /// Endpoint para el registro de nuevos usuarios.
  static String registerEndpoint = '/api/auth/register';

  /// Endpoint para el inicio de sesión de usuarios.
  static String loginEndpoint = '/api/auth/login';
}