import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/perfil_model.dart';
import 'package:mobile_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/models/reporte_resumen_model.dart';
import 'package:mobile_app/models/conversacion_model.dart';
import 'package:mobile_app/models/notificacion_model.dart'; 

class PerfilService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<Perfil> getMiPerfil() async {
    final token = await _getToken();
    if (token == null) throw Exception('Usuario no autenticado');

    final url = Uri.parse('${ApiConstants.baseUrl}/api/perfil/me');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return Perfil.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al cargar el perfil');
      }
    } catch (e) {
      // Catch network errors
      throw Exception('Error de conexión al cargar el perfil');
    }
  }

  // --- THIS FUNCTION IS NOW WRAPPED IN A TRY...CATCH ---
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
        // This will be shown in the UI if the server returns an error
        throw Exception('Error del servidor al cargar la lista');
      }
    } catch (e) {
      // This will be shown if there's a connection error
      throw Exception('Error de conexión');
    }
  }
  Future<List<Conversacion>> getMisConversaciones() async {
    // Use the new helper function
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');

    final url = Uri.parse(ApiConstants.baseUrl + '/api/perfil/me/conversaciones');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((c) => Conversacion.fromJson(c)).toList();
    } else {
      throw Exception('Error al cargar conversaciones');
    }
  }

  Future<List<Notificacion>> getMisNotificaciones() async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');

    final url = Uri.parse(ApiConstants.baseUrl + '/api/perfil/me/notificaciones');
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


  Future<List<ReporteResumen>> getMisReportes() async {
    return _fetchReportList('/api/perfil/me/reportes');
  }

  Future<List<ReporteResumen>> getMisApoyos() async {
    return _fetchReportList('/api/perfil/me/apoyos');
  }

  Future<List<ReporteResumen>> getMisComentarios() async {
    return _fetchReportList('/api/perfil/me/comentarios');
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
  
  Future<bool> updateMyProfile(String nombre, String? alias, String? telefono) async {
    final token = await _getToken();
    if (token == null) return false;
    final url = Uri.parse(ApiConstants.baseUrl + '/api/perfil/me');
    final response = await http.put(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    }, body: json.encode({
      'nombre': nombre,
      'alias': alias,
      'telefono': telefono,
    }));
    return response.statusCode == 200;
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

  Future<Map<String, dynamic>> updateMyPassword(String currentPassword, String newPassword) async {
    final token = await _getToken();
    final url = Uri.parse(ApiConstants.baseUrl + '/api/perfil/me/password');
    final response = await http.put(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    }, body: json.encode({'currentPassword': currentPassword, 'newPassword': newPassword}));
    return {'statusCode': response.statusCode, 'data': json.decode(response.body)};
  }
}