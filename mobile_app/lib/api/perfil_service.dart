import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/models/perfil_model.dart';
import 'package:mobile_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/models/reporte_resumen_model.dart';
import 'package:mobile_app/models/conversacion_model.dart';
import 'package:mobile_app/models/notificacion_model.dart'; 
import 'package:mobile_app/models/historial_pago_model.dart';
import 'package:mobile_app/models/boleta_detalle_model.dart';
import 'package:mobile_app/models/estadisticas_model.dart';
import 'package:mobile_app/models/zona_segura_model.dart'; 

class PerfilService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  /// Obtiene los datos completos del perfil del usuario, incluyendo insignias.
  Future<Perfil> getMiPerfil() async {
    final token = await _getToken();
    if (token == null) throw Exception('Usuario no autenticado');

    final url = Uri.parse('${ApiConstants.baseUrl}/api/perfil/me');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return Perfil.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al cargar el perfil del servidor');
      }
    } catch (e) {
      throw Exception('Error de conexión al cargar el perfil');
    }
  }

  /// Función genérica para obtener listas de actividad del usuario.
  Future<List<ReporteResumen>> _fetchReportList(String endpoint) async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');

    final url = Uri.parse(ApiConstants.baseUrl + endpoint);
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((item) => ReporteResumen.fromJson(item)).toList();
      } else {
        throw Exception('Error del servidor al cargar la lista');
      }
    } catch (e) {
      throw Exception('Error de conexión');
    }
  }

  /// Obtiene los reportes creados por el usuario.
  Future<List<ReporteResumen>> getMisReportes() {
    return _fetchReportList('/api/perfil/me/reportes');
  }

  /// Obtiene los reportes que el usuario ha apoyado.
  Future<List<ReporteResumen>> getMisApoyos() {
    return _fetchReportList('/api/perfil/me/apoyos');
  }

  /// Obtiene los reportes en los que el usuario ha comentado.
  Future<List<ReporteResumen>> getMisComentarios() {
    return _fetchReportList('/api/perfil/me/comentarios');
  }
  
  /// --- FUNCIÓN AÑADIDA ---
  /// Obtiene las conversaciones activas (chats) del usuario (para líderes).
  Future<List<Conversacion>> getMisConversaciones() async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');

    final url = Uri.parse('${ApiConstants.baseUrl}/api/perfil/me/conversaciones');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((c) => Conversacion.fromJson(c)).toList();
    } else {
      throw Exception('Error al cargar conversaciones');
    }
  }

  /// Obtiene el historial de notificaciones del usuario.
  Future<List<Notificacion>> getMisNotificaciones() async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');

    final url = Uri.parse('${ApiConstants.baseUrl}/api/perfil/me/notificaciones');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((n) => Notificacion.fromJson(n)).toList();
      } else {
        throw Exception('Error al cargar notificaciones');
      }
    } catch (e) {
      throw Exception('Error de conexión');
    }
  }

  /// Actualiza los datos básicos del perfil del usuario.
  Future<bool> updateMyProfile(String nombre, String? alias, String? telefono) async {
    final token = await _getToken();
    if (token == null) return false;
    final url = Uri.parse('${ApiConstants.baseUrl}/api/perfil/me');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode({
        'nombre': nombre,
        'alias': alias,
        'telefono': telefono,
      }),
    );
    return response.statusCode == 200;
  }

  /// Actualiza la contraseña del usuario, verificando la actual.
  Future<Map<String, dynamic>> updateMyPassword(String currentPassword, String newPassword) async {
    final token = await _getToken();
    if (token == null) return {'statusCode': 401, 'data': {'message': 'No autenticado'}};
    
    final url = Uri.parse('${ApiConstants.baseUrl}/api/perfil/me/password');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );
    return {'statusCode': response.statusCode, 'data': json.decode(response.body)};
  }

  Future<Map<String, dynamic>> updateMyEmail(String newEmail, String password) async {
    final token = await _getToken();
    final url = Uri.parse(ApiConstants.baseUrl + '/api/perfil/me/email');
    final response = await http.put(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    }, body: json.encode({'newEmail': newEmail, 'password': password}));
    return {'statusCode': response.statusCode, 'data': json.decode(response.body)};
  }

  Future<bool> verifyPassword(String password) async {
    final token = await _getToken();
    if (token == null) return false;
    final url = Uri.parse(ApiConstants.baseUrl + '/api/auth/verify-password');
    final response = await http.post(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    }, body: json.encode({'password': password}));
    return response.statusCode == 200;
  }

  Future<bool> marcarTodasComoLeidas() async {
    final token = await _getToken();
    if (token == null) return false;

    final url = Uri.parse('${ApiConstants.baseUrl}/api/perfil/me/notificaciones/mark-all-read');
    try {
      final response = await http.put(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Obtiene el historial de transacciones de pago del usuario.
  Future<List<HistorialPago>> getHistorialPagos() async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');

    final url = Uri.parse('${ApiConstants.baseUrl}/api/perfil/me/payment-history');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((item) => HistorialPago.fromJson(item)).toList();
      } else {
        throw Exception('Error del servidor al cargar el historial de pagos');
      }
    } catch (e) {
      throw Exception('Error de conexión');
    }
  }

  /// Obtiene los detalles completos de una boleta de pago específica.
  Future<BoletaDetalle> getDetalleBoleta(String transactionId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');

    final url = Uri.parse('${ApiConstants.baseUrl}/api/perfil/me/invoices/$transactionId');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        return BoletaDetalle.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error del servidor al cargar los detalles de la boleta');
      }
    } catch (e) {
      throw Exception('Error de conexión');
    }
  }

Future<EstadisticasResumen> getMisEstadisticasResumen() async {
  final token = await _getToken();
  if (token == null) throw Exception('No autenticado');
  final url = Uri.parse('${ApiConstants.baseUrl}/api/perfil/me/estadisticas/resumen');
  final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
  if (response.statusCode == 200) {
    return EstadisticasResumen.fromJson(json.decode(response.body));
  } else {
    throw Exception('Error al cargar resumen de estadísticas');
  }
}

Future<List<DatoGrafico>> getMisReportesPorCategoria() async {
  final token = await _getToken();
  if (token == null) throw Exception('No autenticado');
  final url = Uri.parse('${ApiConstants.baseUrl}/api/perfil/me/estadisticas/por-categoria');
  final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((item) => DatoGrafico.fromJson(item)).toList();
  } else {
    throw Exception('Error al cargar datos por categoría');
  }
}

/// Obtiene la lista de zonas seguras del usuario.
  Future<List<ZonaSegura>> getMisZonasSeguras() async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');
    final url = Uri.parse('${ApiConstants.baseUrl}/api/perfil/me/zonas-seguras');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((zona) => ZonaSegura.fromJson(zona)).toList();
    } else {
      throw Exception('Error al cargar las zonas seguras');
    }
  }

  /// Crea una nueva zona segura para el usuario.
  Future<bool> crearZonaSegura({
    required String nombre,
    required LatLng centro,
    required int radio,
  }) async {
    final token = await _getToken();
    if (token == null) return false;
    final url = Uri.parse('${ApiConstants.baseUrl}/api/perfil/me/zonas-seguras');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: json.encode({
        'nombre': nombre,
        'lat': centro.latitude,
        'lon': centro.longitude,
        'radio_metros': radio,
      }),
    );
    return response.statusCode == 201;
  }

  /// Elimina una zona segura específica.
  Future<bool> eliminarZonaSegura(int idZona) async {
    final token = await _getToken();
    if (token == null) return false;
    final url = Uri.parse('${ApiConstants.baseUrl}/api/perfil/me/zonas-seguras/$idZona');
    final response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});
    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> postularComoLider({
    required String motivacion,
    required String zonaPropuesta,
  }) async {
    final token = await _getToken();
    if (token == null) return {'statusCode': 401, 'message': 'No autenticado'};
    
    final url = Uri.parse('${ApiConstants.baseUrl}/api/perfil/postular-lider');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: json.encode({
          'motivacion': motivacion,
          'zona_propuesta': zonaPropuesta,
        }),
      );
      // Devolver status code y mensaje del body
      return {'statusCode': response.statusCode, 'message': json.decode(response.body)['message'] ?? 'Respuesta inesperada'};
    } catch (e) {
      print("Error en postularComoLider: $e");
      return {'statusCode': 500, 'message': 'Error de conexión.'};
    }
  }
  // --- FIN MODIFICADO ---

  // --- NUEVO: getStatsActividad ---
  Future<Map<String, int>> getStatsActividad() async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');
    final url = Uri.parse('${ApiConstants.baseUrl}/api/perfil/me/stats/actividad');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data.map((key, value) => MapEntry(key, (value is num) ? value.toInt() : 0));
      } else {
        throw Exception('Error al cargar estadísticas de actividad');
      }
    } catch (e) {
      print("Error fetching activity stats: $e");
      throw Exception('Error de conexión al cargar estadísticas.');
    }
  }

  Future<Map<String, dynamic>> reportarUsuario(int userIdToReport, String motivo) async {
  final token = await _getToken();
  if (token == null) return {'statusCode': 401, 'message': 'No autenticado'};

  // Usa la ruta definida en usuarios.routes.js
  final url = Uri.parse('${ApiConstants.baseUrl}/api/usuarios/$userIdToReport/reportar');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: json.encode({'motivo': motivo}),
    );
    // Devolver status code y mensaje del body
    return {
      'statusCode': response.statusCode,
      'message': json.decode(response.body)['message'] ?? 'Respuesta inesperada'
    };
  } catch (e) {
    print("Error en reportarUsuario Service: $e");
    return {'statusCode': 500, 'message': 'Error de conexión.'};
  }
}
}