// lib/api/lider_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Importar para debugPrint
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/reporte_pendiente_model.dart';
import 'package:mobile_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/models/reporte_moderacion_model.dart';
import 'package:mobile_app/models/solicitud_revision_model.dart';
import 'package:mobile_app/models/reporte_historial_moderado_model.dart';

class PagedResult<T> {
  final List<T> items;
  final bool hasMore;
  final int totalFiltrado; // <-- Añadido

  PagedResult({
    required this.items,
    required this.hasMore,
    required this.totalFiltrado, // <-- Añadido
  });
}

class LiderService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // Obtener Estadísticas (sin cambios)
  Future<Map<String, int>> getModeracionStats() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No autenticado');
    }
    final url = Uri.parse('${ApiConstants.baseUrl}/api/lider/stats/moderacion');
    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // Asegurarse de que los valores sean enteros
        return data.map(
            (key, value) => MapEntry(key, (value is num) ? value.toInt() : 0));
      } else {
        throw Exception(
            'Error ${response.statusCode}: ${json.decode(response.body)['message'] ?? 'Error al cargar estadísticas'}');
      }
    } catch (e) {
      debugPrint("Error fetching moderation stats: $e");
      throw Exception('Error de conexión al cargar estadísticas.');
    }
  }

  Future<PagedResult<ReportePendiente>> getReportesPendientes({
    int page = 1,
    int? categoriaId,
    bool? prioritario,
    bool? conApoyos,
    String? search,
    String? sortBy, // <-- Añadido
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No autenticado');
    }

    final queryParameters = <String, String>{
      'page': page.toString(),
      if (categoriaId != null) 'categoriaId': categoriaId.toString(),
      if (prioritario == true) 'prioritario': 'true',
      if (conApoyos == true) 'conApoyos': 'true',
      if (search != null && search.isNotEmpty) 'search': search,
      if (sortBy != null) 'sortBy': sortBy, // <-- Añadido
    };

    final url =
        Uri.parse('${ApiConstants.baseUrl}/api/lider/reportes-pendientes')
            .replace(queryParameters: queryParameters);

    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = json.decode(response.body);
        final List<dynamic> reportesJson = decodedBody['reportes'] ?? [];
        final bool hasMore = decodedBody['hasMore'] ?? false;
        final int totalFiltrado =
            (decodedBody['totalFiltrado'] as num?)?.toInt() ?? 0;
        final List<ReportePendiente> reportes = reportesJson
            .map((item) => ReportePendiente.fromJson(item))
            .toList();
        return PagedResult(
            items: reportes,
            hasMore: hasMore,
            totalFiltrado: totalFiltrado); // <-- Pasar totalFiltrado
      } else {
        throw Exception(
            'Error ${response.statusCode}: ${json.decode(response.body)['message'] ?? 'Error al cargar pendientes'}');
      }
    } catch (e) {
      debugPrint("Error fetching pending reports: $e");
      throw Exception('Error de conexión al cargar pendientes.');
    }
  }

  Future<PagedResult<ReporteHistorialModerado>> getReportesModerados({
    int page = 1,
    String? estado, // 'verificado', 'rechazado', 'fusionado'
    String? fecha, // 'hoy', 'semana', 'mes' (Mantenido como fallback)
    DateTime? startDate, // <-- Añadido
    DateTime? endDate, // <-- Añadido
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No autenticado');
    }

    final queryParameters = <String, String>{
      'page': page.toString(),
      if (estado != null) 'estado': estado,
      if (fecha != null && startDate == null && endDate == null) 'fecha': fecha,
      if (startDate != null)
        'startDate':
            startDate.toIso8601String().substring(0, 10), // Formato YYYY-MM-DD
      if (endDate != null)
        'endDate':
            endDate.toIso8601String().substring(0, 10), // Formato YYYY-MM-DD
    };

    final url =
        Uri.parse('${ApiConstants.baseUrl}/api/lider/reportes-moderados')
            .replace(queryParameters: queryParameters);

    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = json.decode(response.body);
        final List<dynamic> reportesJson = decodedBody['reportes'] ?? [];
        final bool hasMore = decodedBody['hasMore'] ?? false;
        final int totalFiltrado =
            (decodedBody['totalFiltrado'] as num?)?.toInt() ?? 0;
        final List<ReporteHistorialModerado> reportes = reportesJson
            .map((item) => ReporteHistorialModerado.fromJson(item))
            .toList();
        return PagedResult(
            items: reportes,
            hasMore: hasMore,
            totalFiltrado: totalFiltrado); // <-- Pasar totalFiltrado
      } else {
        throw Exception(
            'Error ${response.statusCode}: ${json.decode(response.body)['message'] ?? 'Error al cargar historial'}');
      }
    } catch (e) {
      debugPrint("Error fetching moderation history: $e");
      throw Exception('Error de conexión al cargar historial.');
    }
  }

  Future<PagedResult<ReporteModeracion>> getMisComentariosReportados({
    int page = 1,
    String? fecha,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No autenticado');
    }

    final queryParameters = <String, String>{
      'page': page.toString(),
      if (fecha != null && startDate == null && endDate == null) 'fecha': fecha,
      if (startDate != null)
        'startDate': startDate.toIso8601String().substring(0, 10),
      if (endDate != null)
        'endDate': endDate.toIso8601String().substring(0, 10),
    };

    final url =
        Uri.parse('${ApiConstants.baseUrl}/api/lider/me/comentarios-reportados')
            .replace(queryParameters: queryParameters);

    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = json.decode(response.body);
        final List<dynamic> reportesJson = decodedBody['reportes'] ?? [];
        final bool hasMore = decodedBody['hasMore'] ?? false;
        final int totalFiltrado =
            (decodedBody['totalFiltrado'] as num?)?.toInt() ?? 0;
        final List<ReporteModeracion> reportes = reportesJson
            .map((item) => ReporteModeracion.fromJson(
                item, TipoReporteModeracion.comentario))
            .toList();
        return PagedResult(
            items: reportes,
            hasMore: hasMore,
            totalFiltrado: totalFiltrado); // <-- Pasar totalFiltrado
      } else {
        throw Exception(
            'Error ${response.statusCode}: ${json.decode(response.body)['message'] ?? 'Error al cargar comentarios reportados'}');
      }
    } catch (e) {
      debugPrint("Error fetching reported comments: $e");
      throw Exception('Error de conexión al cargar reportes.');
    }
  }

  Future<PagedResult<ReporteModeracion>> getMisUsuariosReportados({
    int page = 1,
    String? fecha,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No autenticado');
    }

    final queryParameters = <String, String>{
      'page': page.toString(),
      if (fecha != null && startDate == null && endDate == null) 'fecha': fecha,
      if (startDate != null)
        'startDate': startDate.toIso8601String().substring(0, 10),
      if (endDate != null)
        'endDate': endDate.toIso8601String().substring(0, 10),
    };

    final url =
        Uri.parse('${ApiConstants.baseUrl}/api/lider/me/usuarios-reportados')
            .replace(queryParameters: queryParameters);

    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = json.decode(response.body);
        final List<dynamic> reportesJson = decodedBody['reportes'] ?? [];
        final bool hasMore = decodedBody['hasMore'] ?? false;
        final int totalFiltrado =
            (decodedBody['totalFiltrado'] as num?)?.toInt() ?? 0;
        final List<ReporteModeracion> reportes = reportesJson
            .map((item) =>
                ReporteModeracion.fromJson(item, TipoReporteModeracion.usuario))
            .toList();
        return PagedResult(
            items: reportes,
            hasMore: hasMore,
            totalFiltrado: totalFiltrado); // <-- Pasar totalFiltrado
      } else {
        throw Exception(
            'Error ${response.statusCode}: ${json.decode(response.body)['message'] ?? 'Error al cargar usuarios reportados'}');
      }
    } catch (e) {
      debugPrint("Error fetching reported users: $e");
      throw Exception('Error de conexión al cargar reportes.');
    }
  }

  Future<Map<String, dynamic>> aprobarReporte(int reporteId) async {
    final token = await _getToken();
    if (token == null) {
      return {'statusCode': 401, 'message': 'No autenticado'};
    }
    final url = Uri.parse(
        '${ApiConstants.baseUrl}/api/lider/reportes/$reporteId/aprobar');
    try {
      final response =
          await http.put(url, headers: {'Authorization': 'Bearer $token'});
      final body = json.decode(response.body);
      return {
        'statusCode': response.statusCode,
        'message': body['message'] ?? 'Respuesta inesperada'
      };
    } catch (e) {
      return {'statusCode': 500, 'message': 'Error de conexión.'};
    }
  }

  Future<Map<String, dynamic>> rechazarReporte(int reporteId) async {
    final token = await _getToken();
    if (token == null) {
      return {'statusCode': 401, 'message': 'No autenticado'};
    }
    final url = Uri.parse(
        '${ApiConstants.baseUrl}/api/lider/reportes/$reporteId/rechazar');
    try {
      final response =
          await http.put(url, headers: {'Authorization': 'Bearer $token'});
      final body = json.decode(response.body);
      return {
        'statusCode': response.statusCode,
        'message': body['message'] ?? 'Respuesta inesperada'
      };
    } catch (e) {
      return {'statusCode': 500, 'message': 'Error de conexión.'};
    }
  }

  Future<Map<String, dynamic>> editarReporteLider(
    int reporteId, {
    required String titulo,
    String? descripcion,
    required int idCategoria,
    String? referenciaUbicacion,
    List<String>? tags,
  }) async {
    final token = await _getToken();
    if (token == null) {
      return {'statusCode': 401, 'message': 'No autenticado'};
    }
    final url =
        Uri.parse('${ApiConstants.baseUrl}/api/lider/reporte/$reporteId');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({
          'titulo': titulo,
          'descripcion': descripcion,
          'id_categoria': idCategoria,
          'referencia_ubicacion': referenciaUbicacion,
          'tags': tags,
        }),
      );
      final body = json.decode(response.body);
      return {
        'statusCode': response.statusCode,
        'message': body['message'] ?? 'Respuesta inesperada'
      };
    } catch (e) {
      debugPrint("Error en editarReporteLider: $e");
      return {'statusCode': 500, 'message': 'Error de conexión.'};
    }
  }

  Future<Map<String, dynamic>> fusionarReporte(
      int reporteDuplicadoId, int reporteOriginalId) async {
    final token = await _getToken();
    if (token == null) {
      return {'statusCode': 401, 'message': 'No autenticado'};
    }
    final url = Uri.parse(
        '${ApiConstants.baseUrl}/api/lider/reporte/$reporteDuplicadoId/fusionar');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({'id_reporte_original': reporteOriginalId}),
      );
      final body = json.decode(response.body);
      return {
        'statusCode': response.statusCode,
        'message': body['message'] ?? 'Respuesta inesperada'
      };
    } catch (e) {
      debugPrint("Error en fusionarReporte: $e");
      return {'statusCode': 500, 'message': 'Error de conexión.'};
    }
  }

  Future<Map<String, dynamic>> eliminarReporteModeracion(
      int moderacionReporteId, TipoReporteModeracion tipo) async {
    final token = await _getToken();
    if (token == null) {
      return {'statusCode': 401, 'message': 'No autenticado'};
    }
    final tipoString =
        tipo == TipoReporteModeracion.comentario ? 'comentario' : 'usuario';
    final url = Uri.parse(
        '${ApiConstants.baseUrl}/api/lider/moderacion/$tipoString/$moderacionReporteId');
    try {
      final response =
          await http.delete(url, headers: {'Authorization': 'Bearer $token'});
      String message = 'Eliminado correctamente';
      if (response.body.isNotEmpty) {
        try {
          message = json.decode(response.body)['message'] ?? message;
        } catch (_) {}
      }
      return {'statusCode': response.statusCode, 'message': message};
    } catch (e) {
      debugPrint("Error en eliminarReporteModeracion: $e");
      return {'statusCode': 500, 'message': 'Error de conexión.'};
    }
  }

  Future<List<SolicitudRevision>> getMisSolicitudesRevision() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No autenticado');
    }

    final url =
        Uri.parse('${ApiConstants.baseUrl}/api/lider/me/solicitudes-revision');
    final response =
        await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((item) => SolicitudRevision.fromJson(item))
          .toList();
    } else {
      throw Exception('Error al cargar solicitudes');
    }
  }

  Future<Map<String, dynamic>> solicitarRevision(
      int reporteId, String motivo) async {
    final token = await _getToken();
    if (token == null) {
      return {'statusCode': 401, 'message': 'No autenticado'};
    }
    final url = Uri.parse(
        '${ApiConstants.baseUrl}/api/lider/reportes/$reporteId/solicitar-revision');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({'motivo': motivo}),
      );
      String message = 'Respuesta inesperada';
      if (response.body.isNotEmpty) {
        try {
          message = json.decode(response.body)['message'] ?? message;
        } catch (_) {}
      } else if (response.statusCode == 201) {
        message = 'Solicitud enviada exitosamente.';
      }
      return {'statusCode': response.statusCode, 'message': message};
    } catch (e) {
      debugPrint("Error en solicitarRevision: $e");
      return {'statusCode': 500, 'message': 'Error de conexión.'};
    }
  }

  Future<List<String>> getMisZonasAsignadas() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No autenticado');
    }
    final url =
        Uri.parse('${ApiConstants.baseUrl}/api/lider/me/zonas-asignadas');
    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<String>.from(data);
      } else {
        throw Exception(
            'Error ${response.statusCode}: ${json.decode(response.body)['message'] ?? 'Error al cargar zonas asignadas'}');
      }
    } catch (e) {
      debugPrint("Error fetching assigned zones: $e");
      throw Exception('Error de conexión al cargar zonas.');
    }
  }
}
