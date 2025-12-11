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
  static String baseUrl =
      Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';

  // --- URL Alternativa para Pruebas en Red Local ---
  // Descomenta la siguiente línea y reemplaza la IP si necesitas
  // probar en un dispositivo físico conectado a la misma red WiFi
  // que tu computadora (ej. 192.168.1.10 es la IP de tu PC).
  //static String baseUrl =
      //Platform.isAndroid ? 'http://192.168.100.5:3000' : 'http://localhost:3000';

  //static String baseUrl = 'https://alerta-piura-backend.onrender.com';
  // --------------------------------------------------

  /// Endpoint para el registro de nuevos usuarios.
  static String registerEndpoint = '/api/auth/register';

  /// Endpoint para el inicio de sesión de usuarios.
  static String loginEndpoint = '/api/auth/login';
}
/*
import 'dart:io';

class ApiConstants {
  // --------------------------------------------------
  // CONFIGURACIÓN DE IP (IMPORTANTE)
  // --------------------------------------------------
  // 1. Abre CMD en Windows y escribe: ipconfig
  // 2. Copia la "Dirección IPv4" y pégala aquí abajo:
  //static const String _miIpLocal = '192.168.100.5';
  static const String _miIpLocal = '192.168.56.1';
  // Puerto de tu servidor Node.js
  static const String _puerto = '3000'; 

  /// La URL base del servidor backend.
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Opción A: Celular Físico (Usa la IP de tu PC)
      return 'http://$_miIpLocal:$_puerto';
      
      // Opción B: Emulador de Android (Descomenta si vuelves a usar emulador)
      // return 'http://10.0.2.2:$_puerto'; 
    }
    
    // iOS / Web / Desktop
    return 'http://localhost:$_puerto';
  }

  // Endpoints
  static String registerEndpoint = '/api/auth/register';
  static String loginEndpoint = '/api/auth/login';
}*/