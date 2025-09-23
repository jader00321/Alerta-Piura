import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/models/reporte_model.dart';
import 'package:mobile_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/models/reporte_detallado_model.dart';
import 'package:mobile_app/models/categoria_model.dart';
import 'package:mobile_app/models/chat_message_model.dart';

class ReporteService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<List<Reporte>> getAllReports({Set<int>? categoriaIds}) async {
    String urlString = ApiConstants.baseUrl + '/api/reportes';
    if (categoriaIds != null && categoriaIds.isNotEmpty) {
      urlString += '?categoriaIds=${categoriaIds.join(',')}';
    }
    final url = Uri.parse(urlString);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> reportesJson = json.decode(response.body);
        return reportesJson.map((json) => Reporte.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar los reportes');
      }
    } catch (e) {
      throw Exception('Error de conexión al cargar reportes');
    }
  }

  // --- UPDATED createReport with all new data fields ---
  Future<bool> createReport({
    required int idCategoria,
    required String titulo,
    String? descripcion,
    required LatLng location,
    required bool esAnonimo,
    String? categoriaSugerida,
    String? imagePath,
    // New Fields
    required String urgencia,
    String? horaIncidente,
    List<String>? tags,
    required String impacto,
    String? referenciaUbicacion,
    String? distrito,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/reportes');
    final token = await _getToken();
    if (token == null) return false;

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      // Add all text fields
      request.fields['id_categoria'] = idCategoria.toString();
      request.fields['titulo'] = titulo;
      if (descripcion != null) request.fields['descripcion'] = descripcion;
      request.fields['location'] = json.encode({
        'type': 'Point',
        'coordinates': [location.longitude, location.latitude],
      });
      request.fields['es_anonimo'] = esAnonimo.toString();
      if (categoriaSugerida != null) request.fields['categoria_sugerida'] = categoriaSugerida;
      
      // Add new data fields to the request
      request.fields['urgencia'] = urgencia;
      if (horaIncidente != null) request.fields['hora_incidente'] = horaIncidente;
      if (tags != null && tags.isNotEmpty) {
        // PostgreSQL expects arrays in the format '{ "tag1", "tag2" }'
        request.fields['tags'] = '{${tags.map((t) => '"$t"').join(',')}}';
      }
      request.fields['impacto'] = impacto;
      if (referenciaUbicacion != null) request.fields['referencia_ubicacion'] = referenciaUbicacion;
      if (distrito != null) request.fields['distrito'] = distrito;
      
      // Add image file if it exists
      if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath('foto', imagePath));
      }

      var response = await request.send();
      return response.statusCode == 201;

    } catch (e) {
      print(e); // For debugging
      return false;
    }
  }
  
  Future<Map<String, dynamic>> apoyarReporte(int idReporte) async {
    final token = await _getToken();
    if (token == null) return {'statusCode': 401, 'message': 'Usuario no autenticado'};

    final url = Uri.parse('${ApiConstants.baseUrl}/api/reportes/$idReporte/apoyar');
    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      return {'statusCode': response.statusCode, 'message': json.decode(response.body)['message']};
    } catch (e) {
      return {'statusCode': 500, 'message': 'Error de conexión'};
    }
  }

  Future<ReporteDetallado> getReporteById(int id) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/reportes/$id');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return ReporteDetallado.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al cargar los detalles del reporte');
      }
    } catch(e) {
      throw Exception('Error de conexión o reporte no encontrado');
    }
  }

  Future<bool> createComentario(int idReporte, String comentario) async {
    final token = await _getToken();
    if (token == null) return false;

    final url = Uri.parse('${ApiConstants.baseUrl}/api/reportes/$idReporte/comentarios');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: json.encode({'comentario': comentario}),
    );
    return response.statusCode == 201;
  }

  Future<Map<String, dynamic>> apoyarComentario(int idComentario) async {
    final token = await _getToken();
    if (token == null) return {'statusCode': 401, 'message': 'Usuario no autenticado'};

    final url = Uri.parse('${ApiConstants.baseUrl}/api/comentarios/$idComentario/apoyar');
    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      return {'statusCode': response.statusCode, 'message': json.decode(response.body)['message']};
    } catch (e) {
      return {'statusCode': 500, 'message': 'Error de conexión'};
    }
  }

  Future<bool> editarComentario(int idComentario, String nuevoTexto) async {
    final token = await _getToken();
    if (token == null) return false;
    
    final url = Uri.parse('${ApiConstants.baseUrl}/api/comentarios/$idComentario');
    final response = await http.put(url, headers: {
      'Content-Type': 'application/json', 'Authorization': 'Bearer $token'
    }, body: json.encode({'comentario': nuevoTexto}));
    return response.statusCode == 200;
  }

  Future<bool> eliminarComentario(int idComentario) async {
    final token = await _getToken();
    if (token == null) return false;

    final url = Uri.parse('${ApiConstants.baseUrl}/api/comentarios/$idComentario');
    final response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});
    return response.statusCode == 200;
  }

  Future<bool> reportarComentario(int idComentario, String motivo) async {
    final token = await _getToken();
    if (token == null) return false;

    final url = Uri.parse('${ApiConstants.baseUrl}/api/comentarios/$idComentario/reportar');
    final response = await http.post(url, headers: {
      'Content-Type': 'application/json', 'Authorization': 'Bearer $token'
    }, body: json.encode({'motivo': motivo}));
    return response.statusCode == 201;
  }

  Future<bool> eliminarReporte(int idReporte) async {
    final token = await _getToken();
    if (token == null) return false;

    final url = Uri.parse('${ApiConstants.baseUrl}/api/reportes/$idReporte');
    final response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});
    return response.statusCode == 200;
  }

  Future<int> getRiesgoZona({required LatLng center, required double radius}) async {
    final lat = center.latitude;
    final lon = center.longitude;
    final url = Uri.parse('${ApiConstants.baseUrl}/api/reportes/riesgo-zona?lat=$lat&lon=$lon&radius=$radius');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body)['riesgo'];
      }
      return 0;
    } catch (e) {
      print('Error fetching risk zone: $e');
      return 0;
    }
  }

  Future<List<Categoria>> getCategorias() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/admin/categories');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((cat) => Categoria.fromJson(cat)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<ChatMessage>> getChatHistory(int idReporte) async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');

    final url = Uri.parse(ApiConstants.baseUrl + '/api/reportes/$idReporte/chat');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((msg) => ChatMessage.fromJson(msg)).toList();
    } else {
      throw Exception('Error al cargar historial del chat');
    }
  }
}