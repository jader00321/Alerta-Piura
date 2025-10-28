// lib/api/lider_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/reporte_pendiente_model.dart';
import 'package:mobile_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/models/reporte_moderacion_model.dart';
import 'package:mobile_app/models/solicitud_revision_model.dart';
import 'package:mobile_app/models/reporte_historial_moderado_model.dart';

/// Un contenedor genérico para resultados de paginación de la API.
///
/// Contiene la lista de [items] para la página actual, un booleano [hasMore]
/// que indica si hay más páginas disponibles, y [totalFiltrado] que
/// representa el conteo total de ítems que coinciden con los filtros aplicados.
class PagedResult<T> {
  /// La lista de ítems para la página actual.
  final List<T> items;

  /// `true` si hay más páginas de resultados disponibles, `false` en caso contrario.
  final bool hasMore;

  /// El número total de ítems que coinciden con la consulta/filtros,
  /// independientemente de la paginación.
  final int totalFiltrado;

  /// Crea una instancia de [PagedResult].
  PagedResult({
    required this.items,
    required this.hasMore,
    required this.totalFiltrado,
  });
}

/// Gestiona todas las operaciones de la API relacionadas con el rol de "Líder".
///
/// Esto incluye la moderación de reportes (pendientes, historial),
/// la gestión de reportes de moderación (comentarios, usuarios),
/// y la obtención de estadísticas y datos específicos del líder (zonas, solicitudes).
class LiderService {
  /// Método privado para obtener el token de autenticación guardado localmente.
  ///
  /// Utiliza [SharedPreferences] para buscar el 'authToken'.
  /// Retorna el token como un [String], o [null] si no se encuentra.
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  /// Obtiene las estadísticas de moderación para el líder.
  ///
  /// Consulta el endpoint `/api/lider/stats/moderacion` para obtener conteos
  /// de reportes pendientes, verificados, rechazados, etc.
  ///
  /// Retorna un [Map<String, int>] con los conteos.
  /// Lanza una [Exception] si el usuario no está autenticado, si la API
  /// devuelve un error, o si hay un problema de conexión.
  Future<Map<String, int>> getModeracionStats() async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');
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
      print("Error fetching moderation stats: $e");
      throw Exception('Error de conexión al cargar estadísticas.');
    }
  }

  /// Obtiene una lista paginada de reportes pendientes de moderación.
  ///
  /// Permite filtrar por [page], [categoriaId], [prioritario], [conApoyos],
  /// [search] (término de búsqueda) y [sortBy] (criterio de ordenamiento).
  ///
  /// Retorna un [PagedResult] de [ReportePendiente].
  /// Lanza una [Exception] si el usuario no está autenticado, si la API
  /// devuelve un error, o si hay un problema de conexión.
  Future<PagedResult<ReportePendiente>> getReportesPendientes({
    int page = 1,
    int? categoriaId,
    bool? prioritario,
    bool? conApoyos,
    String? search,
    String? sortBy,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');

    final queryParameters = <String, String>{
      'page': page.toString(),
      if (categoriaId != null) 'categoriaId': categoriaId.toString(),
      if (prioritario == true) 'prioritario': 'true',
      if (conApoyos == true) 'conApoyos': 'true',
      if (search != null && search.isNotEmpty) 'search': search,
      if (sortBy != null) 'sortBy': sortBy,
    };

    final url = Uri.parse('${ApiConstants.baseUrl}/api/lider/reportes-pendientes')
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
            items: reportes, hasMore: hasMore, totalFiltrado: totalFiltrado);
      } else {
        throw Exception(
            'Error ${response.statusCode}: ${json.decode(response.body)['message'] ?? 'Error al cargar pendientes'}');
      }
    } catch (e) {
      print("Error fetching pending reports: $e");
      throw Exception('Error de conexión al cargar pendientes.');
    }
  }

  /// Obtiene un historial paginado de reportes ya moderados.
  ///
  /// Permite filtrar por [page], [estado] ('verificado', 'rechazado', 'fusionado'),
  /// [fecha] ('hoy', 'semana', 'mes') como fallback, o un rango de fechas
  /// preciso usando [startDate] y [endDate].
  ///
  /// Retorna un [PagedResult] de [ReporteHistorialModerado].
  /// Lanza una [Exception] si el usuario no está autenticado, si la API
  /// devuelve un error, o si hay un problema de conexión.
  Future<PagedResult<ReporteHistorialModerado>> getReportesModerados({
    int page = 1,
    String? estado, // 'verificado', 'rechazado', 'fusionado'
    String? fecha, // 'hoy', 'semana', 'mes' (Mantenido como fallback)
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');

    final queryParameters = <String, String>{
      'page': page.toString(),
      if (estado != null) 'estado': estado,
      // Solo añadir 'fecha' si no hay rango preciso
      if (fecha != null && startDate == null && endDate == null) 'fecha': fecha,
      // Añadir fechas precisas si existen
      if (startDate != null)
        'startDate': startDate.toIso8601String().substring(0, 10), // Formato YYYY-MM-DD
      if (endDate != null)
        'endDate': endDate.toIso8601String().substring(0, 10), // Formato YYYY-MM-DD
    };

    final url = Uri.parse('${ApiConstants.baseUrl}/api/lider/reportes-moderados')
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
            items: reportes, hasMore: hasMore, totalFiltrado: totalFiltrado);
      } else {
        throw Exception(
            'Error ${response.statusCode}: ${json.decode(response.body)['message'] ?? 'Error al cargar historial'}');
      }
    } catch (e) {
      print("Error fetching moderation history: $e");
      throw Exception('Error de conexión al cargar historial.');
    }
  }

  /// Obtiene una lista paginada de comentarios reportados por el líder.
  ///
  /// Permite filtrar por [page], [fecha] (fallback) o un rango de fechas
  /// preciso usando [startDate] y [endDate].
  ///
  /// Retorna un [PagedResult] de [ReporteModeracion].
  /// Lanza una [Exception] si el usuario no está autenticado, si la API
  /// devuelve un error, o si hay un problema de conexión.
  Future<PagedResult<ReporteModeracion>> getMisComentariosReportados({
    int page = 1,
    String? fecha, // Fallback
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');

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
            .map((item) =>
                ReporteModeracion.fromJson(item, TipoReporteModeracion.comentario))
            .toList();
        return PagedResult(
            items: reportes, hasMore: hasMore, totalFiltrado: totalFiltrado);
      } else {
        throw Exception(
            'Error ${response.statusCode}: ${json.decode(response.body)['message'] ?? 'Error al cargar comentarios reportados'}');
      }
    } catch (e) {
      print("Error fetching reported comments: $e");
      throw Exception('Error de conexión al cargar reportes.');
    }
  }

  /// Obtiene una lista paginada de usuarios reportados por el líder.
  ///
  /// Permite filtrar por [page], [fecha] (fallback) o un rango de fechas
  /// preciso usando [startDate] y [endDate].
  ///
  /// Retorna un [PagedResult] de [ReporteModeracion].
  /// Lanza una [Exception] si el usuario no está autenticado, si la API
  /// devuelve un error, o si hay un problema de conexión.
  Future<PagedResult<ReporteModeracion>> getMisUsuariosReportados({
    int page = 1,
    String? fecha, // Fallback
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');

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
            items: reportes, hasMore: hasMore, totalFiltrado: totalFiltrado);
      } else {
        throw Exception(
            'Error ${response.statusCode}: ${json.decode(response.body)['message'] ?? 'Error al cargar usuarios reportados'}');
      }
    } catch (e) {
      print("Error fetching reported users: $e");
      throw Exception('Error de conexión al cargar reportes.');
    }
  }

  /// Aprueba un reporte pendiente, cambiándolo a estado "verificado".
  ///
  /// [reporteId]: El ID del reporte a aprobar.
  ///
  /// Retorna un [Map] con `statusCode` y `message`.
  Future<Map<String, dynamic>> aprobarReporte(int reporteId) async {
    final token = await _getToken();
    if (token == null)
      return {'statusCode': 401, 'message': 'No autenticado'};
    final url =
        Uri.parse('${ApiConstants.baseUrl}/api/lider/reportes/$reporteId/aprobar');
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

  /// Rechaza un reporte pendiente, cambiándolo a estado "rechazado".
  ///
  /// [reporteId]: El ID del reporte a rechazar.
  ///
  /// Retorna un [Map] con `statusCode` y `message`.
  Future<Map<String, dynamic>> rechazarReporte(int reporteId) async {
    final token = await _getToken();
    if (token == null)
      return {'statusCode': 401, 'message': 'No autenticado'};
    final url =
        Uri.parse('${ApiConstants.baseUrl}/api/lider/reportes/$reporteId/rechazar');
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

  /// Edita los detalles de un reporte existente.
  ///
  /// [reporteId]: El ID del reporte a editar.
  ///
  /// Retorna un [Map] con `statusCode` y `message`.
  Future<Map<String, dynamic>> editarReporteLider(
    int reporteId, {
    required String titulo,
    String? descripcion,
    required int idCategoria,
    String? referenciaUbicacion,
    List<String>? tags,
  }) async {
    final token = await _getToken();
    if (token == null)
      return {'statusCode': 401, 'message': 'No autenticado'};
    final url = Uri.parse('${ApiConstants.baseUrl}/api/lider/reporte/$reporteId');
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
      print("Error en editarReporteLider: $e");
      return {'statusCode': 500, 'message': 'Error de conexión.'};
    }
  }

  /// Fusiona un reporte duplicado en un reporte original.
  ///
  /// [reporteDuplicadoId]: El ID del reporte que se considera duplicado.
  /// [reporteOriginalId]: El ID del reporte principal al que se fusionará el duplicado.
  ///
  /// Retorna un [Map] con `statusCode` y `message`.
  Future<Map<String, dynamic>> fusionarReporte(
      int reporteDuplicadoId, int reporteOriginalId) async {
    final token = await _getToken();
    if (token == null)
      return {'statusCode': 401, 'message': 'No autenticado'};
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
      print("Error en fusionarReporte: $e");
      return {'statusCode': 500, 'message': 'Error de conexión.'};
    }
  }

  /// Elimina un reporte de moderación (de comentario o usuario) hecho por el líder.
  ///
  /// [moderacionReporteId]: El ID del reporte de moderación a eliminar.
  /// [tipo]: El tipo de reporte ([TipoReporteModeracion.comentario] o [TipoReporteModeracion.usuario]).
  ///
  /// Retorna un [Map] con `statusCode` y `message`.
  Future<Map<String, dynamic>> eliminarReporteModeracion(
      int moderacionReporteId, TipoReporteModeracion tipo) async {
    final token = await _getToken();
    if (token == null)
      return {'statusCode': 401, 'message': 'No autenticado'};
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
      print("Error en eliminarReporteModeracion: $e");
      return {'statusCode': 500, 'message': 'Error de conexión.'};
    }
  }

  /// Obtiene la lista de solicitudes de revisión creadas por el líder.
  ///
  /// Retorna una `List<SolicitudRevision>`.
  /// Lanza una [Exception] si el usuario no está autenticado o si la API falla.
  Future<List<SolicitudRevision>> getMisSolicitudesRevision() async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');

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

  /// Envía una solicitud de revisión para un reporte específico.
  ///
  /// [reporteId]: El ID del reporte para el cual se solicita revisión.
  /// [motivo]: La justificación o motivo de la solicitud de revisión.
  ///
  /// Retorna un [Map] con `statusCode` y `message`.
  Future<Map<String, dynamic>> solicitarRevision(
      int reporteId, String motivo) async {
    final token = await _getToken();
    if (token == null)
      return {'statusCode': 401, 'message': 'No autenticado'};
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
      // Manejar posible cuerpo vacío en éxito
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
      print("Error en solicitarRevision: $e");
      return {'statusCode': 500, 'message': 'Error de conexión.'};
    }
  }

  /// Obtiene la lista de zonas (distritos) asignadas al líder.
  ///
  /// Retorna una `List<String>` con los nombres de las zonas.
  /// Lanza una [Exception] si el usuario no está autenticado, si la API
  /// devuelve un error, o si hay un problema de conexión.
  Future<List<String>> getMisZonasAsignadas() async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');
    final url =
        Uri.parse('${ApiConstants.baseUrl}/api/lider/me/zonas-asignadas');
    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        // La API devuelve directamente una lista de strings
        final List<dynamic> data = json.decode(response.body);
        return List<String>.from(data);
      } else {
        throw Exception(
            'Error ${response.statusCode}: ${json.decode(response.body)['message'] ?? 'Error al cargar zonas asignadas'}');
      }
    } catch (e) {
      print("Error fetching assigned zones: $e");
      throw Exception('Error de conexión al cargar zonas.');
    }
  }
}