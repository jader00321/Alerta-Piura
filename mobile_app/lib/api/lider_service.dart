import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/reporte_pendiente_model.dart';
import 'package:mobile_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/models/reporte_moderacion_model.dart';
import 'package:mobile_app/models/solicitud_revision_model.dart';

class LiderService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<List<ReportePendiende>> getReportesPendientes() async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');
    
    final url = Uri.parse('${ApiConstants.baseUrl}/api/lider/reportes-pendientes');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => ReportePendiende.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar reportes pendientes');
    }
  }

  Future<bool> aprobarReporte(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');
    
    final url = Uri.parse('${ApiConstants.baseUrl}/api/lider/reportes/$id/aprobar');
    final response = await http.put(url, headers: {'Authorization': 'Bearer $token'});
    return response.statusCode == 200;
  }
  
  Future<bool> rechazarReporte(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');

    final url = Uri.parse('${ApiConstants.baseUrl}/api/lider/reportes/$id/rechazar');
    final response = await http.put(url, headers: {'Authorization': 'Bearer $token'});
    return response.statusCode == 200;
  }

  Future<List<ReportePendiende>> getReportesModerados() async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');

    final url = Uri.parse('${ApiConstants.baseUrl}/api/lider/reportes-moderados');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      // Reutilizamos el mismo modelo
      return jsonResponse.map((item) => ReportePendiende.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar el historial');
    }
  }

  Future<bool> reportarUsuario(int idUsuario, String motivo) async {
    final token = await _getToken();
    if (token == null) return false;

    final url = Uri.parse('${ApiConstants.baseUrl}/api/usuarios/$idUsuario/reportar');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: json.encode({'motivo': motivo}),
    );
    return response.statusCode == 201;
  }

  Future<List<ReporteModeracion>> getMisComentariosReportados() async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');
    
    final url = Uri.parse('${ApiConstants.baseUrl}/api/lider/me/comentarios-reportados');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => ReporteModeracion.fromJson(item, TipoReporteModeracion.comentario)).toList();
    } else {
      throw Exception('Error al cargar comentarios reportados');
    }
  }
  
  Future<List<ReporteModeracion>> getMisUsuariosReportados() async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');
    
    final url = Uri.parse('${ApiConstants.baseUrl}/api/lider/me/usuarios-reportados');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => ReporteModeracion.fromJson(item, TipoReporteModeracion.usuario)).toList();
    } else {
      throw Exception('Error al cargar usuarios reportados');
    }
  }

  Future<bool> solicitarRevision(int reporteId) async {
    final token = await _getToken();
    if (token == null) return false;
    
    final url = Uri.parse('${ApiConstants.baseUrl}/api/lider/reportes/$reporteId/solicitar-revision');
    final response = await http.post(url, headers: {'Authorization': 'Bearer $token'});
    return response.statusCode == 200;
  }

  Future<List<SolicitudRevision>> getMisSolicitudesRevision() async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');

    final url = Uri.parse('${ApiConstants.baseUrl}/api/lider/me/solicitudes-revision');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => SolicitudRevision.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar solicitudes');
    }
  }
}