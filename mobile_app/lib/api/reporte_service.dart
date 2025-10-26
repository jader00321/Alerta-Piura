import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/models/reporte_model.dart';
import 'package:mobile_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/models/reporte_detallado_model.dart';
import 'package:mobile_app/models/categoria_model.dart';
import 'package:mobile_app/models/chat_message_model.dart';
import 'package:mobile_app/models/reporte_cercano_model.dart';

class FiltrosCercanos {
  final int? categoriaId;
  final String? estado;
  final String? urgencia;
  final int? dias;

  FiltrosCercanos({this.categoriaId, this.estado, this.urgencia, this.dias});

  Map<String, String> toQueryParameters() {
    final Map<String, String> params = {};
    if (categoriaId != null) {
      params['categoriaId'] = categoriaId.toString();
    }
    if (estado != null) {
      params['estado'] = estado!;
    }
    if (urgencia != null) {
      params['urgencia'] = urgencia!;
    }
    if (dias != null) {
      params['dias'] = dias.toString();
    }
    return params;
  }
}

class ReporteService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<List<Reporte>> getAllReports({
    Map<String, String>? filters,
    required String search,
    required String estado,
    required int limit,
  }) async {
    final baseUrl = '${ApiConstants.baseUrl}/api/reportes';
    final queryParameters = <String, String>{};

    queryParameters['status'] = estado;
    queryParameters['limit'] = limit.toString();

    if (search.isNotEmpty) {
      queryParameters['searchQuery'] = search;
    }

    if (filters != null && filters.isNotEmpty) {
      if (filters.containsKey('categoriaId') && filters['categoriaId']!.isNotEmpty) {
        queryParameters['categoriaIds'] = filters['categoriaId']!;
      }
      if (filters.containsKey('dias') && filters['dias']!.isNotEmpty) {
        queryParameters['dateRange'] = filters['dias']!;
      }
    }

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParameters);
    debugPrint("API Request URL (getAllReports): $uri");

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> reportesJson = json.decode(response.body);
        return reportesJson.map((jsonMap) => Reporte.fromJson(jsonMap)).toList();
      } else {
        throw Exception('Error al cargar los reportes (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      debugPrint("Error en getAllReports: $e");
      throw Exception('Error de conexión al cargar reportes: $e');
    }
  }

  Future<List<ReporteCercano>> getReportesCercanos(
    LatLng location, {
    double radius = 500,
    FiltrosCercanos? filtros,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Usuario no autenticado');
    }

    final queryParameters = {
      'lat': location.latitude.toString(),
      'lon': location.longitude.toString(),
      'radius': radius.toString(),
      ...?filtros?.toQueryParameters(),
    };

    final url = Uri.parse('${ApiConstants.baseUrl}/api/reportes/v1/cercanos').replace(
      queryParameters: queryParameters,
    );
    debugPrint("API Request URL (getReportesCercanos): $url");

    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final List<dynamic> reportesJson = json.decode(response.body);
        return reportesJson.map((jsonMap) => ReporteCercano.fromJson(jsonMap)).toList();
      } else {
        String errorMessage = 'Falló al cargar reportes cercanos.';
        try {
          final decodedBody = json.decode(response.body);
          if (decodedBody['message'] != null) {
            errorMessage = decodedBody['message'];
          }
        } catch (_) {
          debugPrint("Error Body (Nearby Reports): ${response.body}");
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint("Connection Error (Nearby Reports): $e");
      throw Exception('Error de conexión al buscar reportes cercanos.');
    }
  }

  Future<Map<String, dynamic>> unirseReportePendiente(int reporteId) async {
    final token = await _getToken();
    if (token == null) {
      return {'statusCode': 401, 'message': 'Usuario no autenticado'};
    }
    final url = Uri.parse('${ApiConstants.baseUrl}/api/reportes/$reporteId/unirse_pendiente');
    try {
      final response = await http.post(url, headers: {'Authorization': 'Bearer $token'});
      final Map<String, dynamic> body = json.decode(response.body);
      return {
        'statusCode': response.statusCode,
        'message': body['message'] ?? 'Respuesta inesperada.',
        'currentApoyos': body['currentApoyos']
      };
    } catch (e) {
      debugPrint("Connection Error (Join Report): $e");
      return {'statusCode': 500, 'message': 'Error de conexión.'};
    }
  }

  Future<bool> createReport({
    required int idCategoria,
    required String titulo,
    String? descripcion,
    required LatLng location,
    required bool esAnonimo,
    String? categoriaSugerida,
    String? imagePath,
    required String urgencia,
    String? horaIncidente,
    List<String>? tags,
    required String impacto,
    String? referenciaUbicacion,
    String? distrito,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/reportes');
    final token = await _getToken();
    if (token == null) {
      return false;
    }

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['id_categoria'] = idCategoria.toString();
      request.fields['titulo'] = titulo;
      if (descripcion != null) {
        request.fields['descripcion'] = descripcion;
      }
      request.fields['location'] = json.encode({
        'type': 'Point',
        'coordinates': [location.longitude, location.latitude],
      });
      request.fields['es_anonimo'] = esAnonimo.toString();
      if (categoriaSugerida != null) {
        request.fields['categoria_sugerida'] = categoriaSugerida;
      }
      request.fields['urgencia'] = urgencia;
      if (horaIncidente != null) {
        request.fields['hora_incidente'] = horaIncidente;
      }
      if (tags != null && tags.isNotEmpty) {
        request.fields['tags'] = '{${tags.map((t) => '"$t"').join(',')}}';
      }
      request.fields['impacto'] = impacto;
      if (referenciaUbicacion != null) {
        request.fields['referencia_ubicacion'] = referenciaUbicacion;
      }
      if (distrito != null) {
        request.fields['distrito'] = distrito;
      }

      if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath('foto', imagePath));
      }

      var response = await request.send();
      return response.statusCode == 201;

    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<Map<String, dynamic>> apoyarReporte(int idReporte) async {
    final token = await _getToken();
    if (token == null) {
      return {'statusCode': 401, 'message': 'Usuario no autenticado'};
    }

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
    final token = await _getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/api/reportes/$id');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        return ReporteDetallado.fromJson(json.decode(response.body));
      } else {
         debugPrint("Error Body (Report Details): ${response.body}");
        throw Exception('Error al cargar los detalles del reporte (${response.statusCode})');
      }
    } catch(e) {
       debugPrint("Connection Error (Report Details): $e");
      throw Exception('Error de conexión o reporte no encontrado');
    }
  }

  Future<bool> createComentario(int idReporte, String comentario) async {
    final token = await _getToken();
    if (token == null) {
      return false;
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/api/comentarios');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: json.encode({
        'id_reporte': idReporte,
        'comentario': comentario
      }),
    );
    return response.statusCode == 201;
  }

  Future<Map<String, dynamic>> apoyarComentario(int idComentario) async {
    final token = await _getToken();
    if (token == null) {
      return {'statusCode': 401, 'message': 'Usuario no autenticado'};
    }

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
    if (token == null) {
      return false;
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/api/comentarios/$idComentario');
    final response = await http.put(url, headers: {
      'Content-Type': 'application/json', 'Authorization': 'Bearer $token'
    }, body: json.encode({'comentario': nuevoTexto}));
    return response.statusCode == 200;
  }

  Future<bool> eliminarComentario(int idComentario) async {
    final token = await _getToken();
    if (token == null) {
      return false;
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/api/comentarios/$idComentario');
    final response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});
    return response.statusCode == 200;
  }

  Future<bool> reportarComentario(int idComentario, String motivo) async {
    final token = await _getToken();
    if (token == null) {
      return false;
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/api/comentarios/$idComentario/reportar');
    final response = await http.post(url, headers: {
      'Content-Type': 'application/json', 'Authorization': 'Bearer $token'
    }, body: json.encode({'motivo': motivo}));
    return response.statusCode == 201;
  }

  Future<bool> eliminarReporte(int idReporte) async {
    final token = await _getToken();
    if (token == null) {
      return false;
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/api/reportes/$idReporte');
    final response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});
    return response.statusCode == 200;
  }

  Future<int> getRiesgoZona(LatLng center, {required LatLng centerPoint, required double radius}) async {
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
      debugPrint('Error fetching risk zone: $e');
      return 0;
    }
  }

  Future<List<Categoria>> getCategorias() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/categorias');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        var categorias = jsonResponse.map((cat) => Categoria.fromJson(cat)).toList();
        categorias.sort((a, b) => a.nombre.compareTo(b.nombre));
        return categorias;
      } else {
         String errorMessage = 'Error al cargar categorías';
         try {
           errorMessage = json.decode(response.body)['message'] ?? errorMessage;
         } catch (_) {}
         throw Exception('Error ${response.statusCode}: $errorMessage');
      }
    } catch (e) {
      debugPrint("Error en getCategorias: $e");
      throw Exception('Error de conexión al cargar categorías.');
    }
  }

  Future<List<ChatMessage>> getChatHistory(int idReporte) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No autenticado');
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/api/reportes/$idReporte/chat');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((msg) => ChatMessage.fromJson(msg)).toList();
    } else {
      throw Exception('Error al cargar historial del chat');
    }
  }

  Future<List<LatLng>> getDatosMapaDeCalor() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/reportes/mapa-calor');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((coords) => LatLng(coords[0], coords[1])).toList();
      } else {
        throw Exception('Error al cargar datos del mapa de calor');
      }
    } catch (e) {
      throw Exception('Error de conexión al cargar mapa de calor');
    }
  }

  Future<List<LatLng>> getZonasPeligrosas() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/reportes/zonas-peligrosas');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((coords) => LatLng(coords[0], coords[1])).toList();
      } else {
        throw Exception('Error al cargar zonas peligrosas');
      }
    } catch (e) {
      throw Exception('Error de conexión al cargar zonas peligrosas');
    }
  }

  Future<Map<String, dynamic>> quitarApoyoPendiente(int reporteId) async {
    final token = await _getToken();
    if (token == null) {
      return {'statusCode': 401, 'message': 'Usuario no autenticado'};
    }
    final url = Uri.parse('${ApiConstants.baseUrl}/api/reportes/$reporteId/unirse_pendiente');
    try {
      final response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});
      final Map<String, dynamic> body = json.decode(response.body);
      return {
        'statusCode': response.statusCode,
        'message': body['message'] ?? 'Respuesta inesperada.',
        'currentApoyos': body['currentApoyos']
      };
    } catch (e) {
      debugPrint("Connection Error (Unjoin Report): $e");
      return {'statusCode': 500, 'message': 'Error de conexión.'};
    }
  }

  Future<Map<String, dynamic>> editarReporteAutor(int reporteId, {
    required String titulo,
    String? descripcion,
    required int idCategoria,
    String? referenciaUbicacion,
    List<String>? tags,
    required String urgencia,
    String? horaIncidente,
    required String impacto,
    String? distrito,
  }) async {
    final token = await _getToken();
    if (token == null) {
      return {'statusCode': 401, 'message': 'No autenticado'};
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/api/reportes/$reporteId/author-edit');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: json.encode({
          'titulo': titulo,
          'descripcion': descripcion,
          'id_categoria': idCategoria,
          'referencia_ubicacion': referenciaUbicacion,
          'tags': tags,
          'urgencia': urgencia,
          'hora_incidente': horaIncidente,
          'impacto': impacto,
          'distrito': distrito,
        }),
      );
      final body = json.decode(response.body);
      return {'statusCode': response.statusCode, 'message': body['message'] ?? 'Respuesta inesperada'};
    } catch (e) {
      debugPrint("Error en editarReporteAutor Service: $e");
      return {'statusCode': 500, 'message': 'Error de conexión.'};
    }
  }
}