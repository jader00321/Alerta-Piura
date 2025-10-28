// lib/api/reporte_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/models/reporte_model.dart';
import 'package:mobile_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/models/reporte_detallado_model.dart';
import 'package:mobile_app/models/categoria_model.dart';
import 'package:mobile_app/models/chat_message_model.dart';
import 'package:mobile_app/models/reporte_cercano_model.dart';

/// Define un conjunto de filtros opcionales para la búsqueda de reportes cercanos.
class FiltrosCercanos {
  /// El ID de la categoría para filtrar.
  final int? categoriaId;

  /// El estado del reporte (ej. 'verificado').
  final String? estado;

  /// El nivel de urgencia (ej. 'alta').
  final String? urgencia;

  /// El rango de días para filtrar (ej. últimos 7 días).
  final int? dias;

  /// Crea una instancia de [FiltrosCercanos].
  FiltrosCercanos({this.categoriaId, this.estado, this.urgencia, this.dias});

  /// Convierte los filtros definidos en un mapa de parámetros de consulta HTTP.
  Map<String, String> toQueryParameters() {
    final Map<String, String> params = {};
    if (categoriaId != null) params['categoriaId'] = categoriaId.toString();
    if (estado != null) params['estado'] = estado!;
    if (urgencia != null) params['urgencia'] = urgencia!;
    if (dias != null) params['dias'] = dias.toString();
    return params;
  }
}

/// Gestiona todas las operaciones de la API relacionadas con reportes y categorías.
///
/// Incluye la creación, lectura, actualización y eliminación (CRUD) de reportes,
/// así como la gestión de comentarios, apoyos, y la obtención de datos
/// geoespaciales (mapa de calor, riesgo).
class ReporteService {
  /// Método privado para obtener el token de autenticación guardado localmente.
  ///
  /// Utiliza [SharedPreferences] para buscar el 'authToken'.
  /// Retorna el token como un [String], o [null] si no se encuentra.
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  /// Obtiene una lista de reportes basada en filtros, búsqueda y estado.
  ///
  /// Esta función pública se usa para el mapa principal y la búsqueda.
  ///
  /// - [filters]: Mapa opcional con 'categoriaId' y 'dias'.
  /// - [search]: Término de búsqueda (backend espera 'searchQuery').
  /// - [estado]: Estado del reporte, 'pendiente_verificacion' o 'verificado' (backend espera 'status').
  /// - [limit]: Número máximo de resultados a devolver.
  ///
  /// Lanza una [Exception] si la petición falla.
  Future<List<Reporte>> getAllReports({
    Map<String, String>? filters,
    required String search,
    required String estado,
    required int limit,
  }) async {
    // 1. Empezar con la URL base
    final baseUrl = '${ApiConstants.baseUrl}/api/reportes';

    // 2. Crear mapa de parámetros de consulta
    final queryParameters = <String, String>{};

    // Añadir estado (siempre se envía)
    queryParameters['status'] = estado;

    // Añadir límite (siempre se envía)
    queryParameters['limit'] = limit.toString();

    // Añadir búsqueda si no está vacía
    if (search.isNotEmpty) {
      queryParameters['searchQuery'] = search;
    }

    // Añadir filtros adicionales (categoría, días)
    if (filters != null && filters.isNotEmpty) {
      if (filters.containsKey('categoriaId') && filters['categoriaId']!.isNotEmpty) {
        queryParameters['categoriaIds'] = filters['categoriaId']!;
      }
      if (filters.containsKey('dias') && filters['dias']!.isNotEmpty) {
        queryParameters['dateRange'] = filters['dias']!;
      }
    }

    // 3. Construir la Uri final con los parámetros
    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParameters);
    print("API Request URL (getAllReports): $uri"); // Para depuración

    try {
      // 4. Hacer la petición GET usando la URI construida
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> reportesJson = json.decode(response.body);
        return reportesJson.map((json) => Reporte.fromJson(json)).toList();
      } else {
        throw Exception(
            'Error al cargar los reportes (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print("Error en getAllReports: $e");
      throw Exception('Error de conexión al cargar reportes: $e');
    }
  }

  /// Obtiene reportes cercanos a una ubicación específica.
  ///
  /// [location]: Las coordenadas [LatLng] del centro de la búsqueda.
  /// [radius]: El radio de búsqueda en metros (por defecto 500).
  /// [filtros]: Objeto [FiltrosCercanos] opcional para refinar la búsqueda.
  ///
  /// Lanza una [Exception] si el usuario no está autenticado o si la API falla.
  Future<List<ReporteCercano>> getReportesCercanos(
    LatLng location, {
    double radius = 500,
    FiltrosCercanos? filtros,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Usuario no autenticado');

    final queryParameters = {
      'lat': location.latitude.toString(),
      'lon': location.longitude.toString(),
      'radius': radius.toString(),
      ...?filtros?.toQueryParameters(),
    };

    final url = Uri.parse('${ApiConstants.baseUrl}/api/reportes/v1/cercanos')
        .replace(
      queryParameters: queryParameters,
    );
    print("API Request URL (getReportesCercanos): $url"); // Para depuración

    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final List<dynamic> reportesJson = json.decode(response.body);
        return reportesJson
            .map((json) => ReporteCercano.fromJson(json))
            .toList();
      } else {
        String errorMessage = 'Falló al cargar reportes cercanos.';
        try {
          final decodedBody = json.decode(response.body);
          if (decodedBody['message'] != null)
            errorMessage = decodedBody['message'];
        } catch (_) {
          print("Error Body (Nearby Reports): ${response.body}");
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("Connection Error (Nearby Reports): $e");
      throw Exception('Error de conexión al buscar reportes cercanos.');
    }
  }

  /// Permite a un usuario "unirse" (apoyar) un reporte que aún está pendiente.
  ///
  /// [reporteId]: El ID del reporte pendiente al que se unirá.
  ///
  /// Retorna un [Map] con `statusCode`, `message` y `currentApoyos`.
  Future<Map<String, dynamic>> unirseReportePendiente(int reporteId) async {
    final token = await _getToken();
    if (token == null)
      return {'statusCode': 401, 'message': 'Usuario no autenticado'};
    final url = Uri.parse(
        '${ApiConstants.baseUrl}/api/reportes/$reporteId/unirse_pendiente');
    try {
      final response =
          await http.post(url, headers: {'Authorization': 'Bearer $token'});
      final Map<String, dynamic> body = json.decode(response.body);
      return {
        'statusCode': response.statusCode,
        'message': body['message'] ?? 'Respuesta inesperada.',
        'currentApoyos': body['currentApoyos']
      };
    } catch (e) {
      print("Connection Error (Join Report): $e");
      return {'statusCode': 500, 'message': 'Error de conexión.'};
    }
  }

  /// Crea un nuevo reporte en el sistema.
  ///
  /// Esta función utiliza una petición `MultipartRequest` para poder
  /// enviar una imagen ([imagePath]) junto con los demás datos del formulario.
  ///
  /// Retorna `true` si el reporte se crea exitosamente (código 201).
  /// Retorna `false` en cualquier otro caso (token nulo, error de API, error de conexión).
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
    if (token == null) return false;

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['id_categoria'] = idCategoria.toString();
      request.fields['titulo'] = titulo;
      if (descripcion != null) request.fields['descripcion'] = descripcion;
      request.fields['location'] = json.encode({
        'type': 'Point',
        'coordinates': [location.longitude, location.latitude],
      });
      request.fields['es_anonimo'] = esAnonimo.toString();
      if (categoriaSugerida != null)
        request.fields['categoria_sugerida'] = categoriaSugerida;
      request.fields['urgencia'] = urgencia;
      if (horaIncidente != null) request.fields['hora_incidente'] = horaIncidente;
      if (tags != null && tags.isNotEmpty) {
        request.fields['tags'] = '{${tags.map((t) => '"$t"').join(',')}}';
      }
      request.fields['impacto'] = impacto;
      if (referenciaUbicacion != null)
        request.fields['referencia_ubicacion'] = referenciaUbicacion;
      if (distrito != null) request.fields['distrito'] = distrito;

      if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath('foto', imagePath));
      }

      var response = await request.send();
      return response.statusCode == 201;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Registra el apoyo de un usuario a un reporte verificado.
  ///
  /// [idReporte]: El ID del reporte a apoyar.
  ///
  /// Retorna un [Map] con `statusCode` y `message`.
  Future<Map<String, dynamic>> apoyarReporte(int idReporte) async {
    final token = await _getToken();
    if (token == null)
      return {'statusCode': 401, 'message': 'Usuario no autenticado'};

    final url =
        Uri.parse('${ApiConstants.baseUrl}/api/reportes/$idReporte/apoyar');
    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      return {
        'statusCode': response.statusCode,
        'message': json.decode(response.body)['message']
      };
    } catch (e) {
      return {'statusCode': 500, 'message': 'Error de conexión'};
    }
  }

  /// Obtiene los detalles completos de un reporte específico.
  ///
  /// [id]: El ID del reporte a consultar.
  ///
  /// Retorna un objeto [ReporteDetallado].
  /// Lanza una [Exception] si la API falla o si hay un error de conexión.
  Future<ReporteDetallado> getReporteById(int id) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/api/reportes/$id');
    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        return ReporteDetallado.fromJson(json.decode(response.body));
      } else {
        print("Error Body (Report Details): ${response.body}");
        throw Exception(
            'Error al cargar los detalles del reporte (${response.statusCode})');
      }
    } catch (e) {
      print("Connection Error (Report Details): $e");
      throw Exception('Error de conexión o reporte no encontrado');
    }
  }

  /// Crea un nuevo comentario en un reporte.
  ///
  /// [idReporte]: El ID del reporte donde se publicará el comentario.
  /// [comentario]: El texto del comentario.
  ///
  /// Retorna `true` si se crea exitosamente (código 201).
  /// Retorna `false` en cualquier otro caso.
  Future<bool> createComentario(int idReporte, String comentario) async {
    final token = await _getToken();
    if (token == null) return false;

    final url = Uri.parse('${ApiConstants.baseUrl}/api/comentarios');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode({'id_reporte': idReporte, 'comentario': comentario}),
    );
    return response.statusCode == 201;
  }

  /// Registra el apoyo (like) de un usuario a un comentario.
  ///
  /// [idComentario]: El ID del comentario a apoyar.
  ///
  /// Retorna un [Map] con `statusCode` y `message`.
  Future<Map<String, dynamic>> apoyarComentario(int idComentario) async {
    final token = await _getToken();
    if (token == null)
      return {'statusCode': 401, 'message': 'Usuario no autenticado'};

    final url =
        Uri.parse('${ApiConstants.baseUrl}/api/comentarios/$idComentario/apoyar');
    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      return {
        'statusCode': response.statusCode,
        'message': json.decode(response.body)['message']
      };
    } catch (e) {
      return {'statusCode': 500, 'message': 'Error de conexión'};
    }
  }

  /// Edita el texto de un comentario existente.
  ///
  /// [idComentario]: El ID del comentario a editar.
  /// [nuevoTexto]: El nuevo contenido del comentario.
  ///
  /// Retorna `true` si la edición es exitosa (código 200).
  /// Retorna `false` en cualquier otro caso.
  Future<bool> editarComentario(int idComentario, String nuevoTexto) async {
    final token = await _getToken();
    if (token == null) return false;

    final url = Uri.parse('${ApiConstants.baseUrl}/api/comentarios/$idComentario');
    final response = await http.put(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({'comentario': nuevoTexto}));
    return response.statusCode == 200;
  }

  /// Elimina un comentario.
  ///
  /// [idComentario]: El ID del comentario a eliminar.
  ///
  /// Retorna `true` si la eliminación es exitosa (código 200).
  /// Retorna `false` en cualquier otro caso.
  Future<bool> eliminarComentario(int idComentario) async {
    final token = await _getToken();
    if (token == null) return false;

    final url = Uri.parse('${ApiConstants.baseUrl}/api/comentarios/$idComentario');
    final response =
        await http.delete(url, headers: {'Authorization': 'Bearer $token'});
    return response.statusCode == 200;
  }

  /// Reporta un comentario por contenido inapropiado.
  ///
  /// [idComentario]: El ID del comentario a reportar.
  /// [motivo]: La justificación del reporte.
  ///
  /// Retorna `true` si el reporte se crea exitosamente (código 201).
  /// Retorna `false` en cualquier otro caso.
  Future<bool> reportarComentario(int idComentario, String motivo) async {
    final token = await _getToken();
    if (token == null) return false;

    final url =
        Uri.parse('${ApiConstants.baseUrl}/api/comentarios/$idComentario/reportar');
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({'motivo': motivo}));
    return response.statusCode == 201;
  }

  /// Elimina un reporte. (Solo el autor o un moderador pueden hacerlo).
  ///
  /// [idReporte]: El ID del reporte a eliminar.
  ///
  /// Retorna `true` si la eliminación es exitosa (código 200).
  /// Retorna `false` en cualquier otro caso.
  Future<bool> eliminarReporte(int idReporte) async {
    final token = await _getToken();
    if (token == null) return false;

    final url = Uri.parse('${ApiConstants.baseUrl}/api/reportes/$idReporte');
    final response =
        await http.delete(url, headers: {'Authorization': 'Bearer $token'});
    return response.statusCode == 200;
  }

  /// Obtiene un nivel de riesgo (0-100) para una zona circular.
  ///
  /// [center]: Las coordenadas [LatLng] del centro de la zona.
  /// [radius]: El radio de la zona en metros.
  ///
  /// Retorna un entero `riesgo`. Devuelve `0` si falla la petición.
  Future<int> getRiesgoZona(LatLng center,
      {required LatLng centerPoint, required double radius}) async {
    final lat = center.latitude;
    final lon = center.longitude;
    final url = Uri.parse(
        '${ApiConstants.baseUrl}/api/reportes/riesgo-zona?lat=$lat&lon=$lon&radius=$radius');

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

  /// Obtiene la lista de todas las categorías de reportes disponibles.
  ///
  /// Lanza una [Exception] si la API falla o hay un error de conexión.
  Future<List<Categoria>> getCategorias() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/categorias');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        var categorias =
            jsonResponse.map((cat) => Categoria.fromJson(cat)).toList();
        // Ordenar por nombre como fallback
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
      print("Error en getCategorias: $e");
      throw Exception('Error de conexión al cargar categorías.');
    }
  }

  /// Obtiene el historial de mensajes del chat de un reporte (para líderes).
  ///
  /// [idReporte]: El ID del reporte cuyo chat se quiere consultar.
  ///
  /// Lanza una [Exception] si el usuario no está autenticado o si la API falla.
  Future<List<ChatMessage>> getChatHistory(int idReporte) async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');

    final url =
        Uri.parse(ApiConstants.baseUrl + '/api/reportes/$idReporte/chat');
    final response =
        await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((msg) => ChatMessage.fromJson(msg)).toList();
    } else {
      throw Exception('Error al cargar historial del chat');
    }
  }

  /// Obtiene los datos (coordenadas) para el mapa de calor.
  ///
  /// Retorna una `List<LatLng>`.
  /// Lanza una [Exception] si la API falla o hay un error de conexión.
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

  /// Obtiene las coordenadas de las zonas peligrosas predefinidas.
  ///
  /// Retorna una `List<LatLng>`.
  /// Lanza una [Exception] si la API falla o hay un error de conexión.
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

  /// Permite a un usuario quitar su apoyo (dejar de "unirse") a un reporte pendiente.
  ///
  /// [reporteId]: El ID del reporte pendiente del que se desvinculará.
  ///
  /// Retorna un [Map] con `statusCode`, `message` y `currentApoyos`.
  Future<Map<String, dynamic>> quitarApoyoPendiente(int reporteId) async {
    final token = await _getToken();
    if (token == null)
      return {'statusCode': 401, 'message': 'Usuario no autenticado'};
    final url = Uri.parse(
        '${ApiConstants.baseUrl}/api/reportes/$reporteId/unirse_pendiente');
    try {
      final response =
          await http.delete(url, headers: {'Authorization': 'Bearer $token'});
      final Map<String, dynamic> body = json.decode(response.body);
      return {
        'statusCode': response.statusCode,
        'message': body['message'] ?? 'Respuesta inesperada.',
        'currentApoyos': body['currentApoyos']
      };
    } catch (e) {
      print("Connection Error (Unjoin Report): $e");
      return {'statusCode': 500, 'message': 'Error de conexión.'};
    }
  }

  /// Permite al autor original de un reporte editar sus detalles.
  ///
  /// [reporteId]: El ID del reporte a editar.
  ///
  /// Retorna un [Map] con `statusCode` y `message`.
  Future<Map<String, dynamic>> editarReporteAutor(
    int reporteId, {
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
    if (token == null)
      return {'statusCode': 401, 'message': 'No autenticado'};

    final url =
        Uri.parse('${ApiConstants.baseUrl}/api/reportes/$reporteId/author-edit');
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
          'urgencia': urgencia,
          'hora_incidente': horaIncidente,
          'impacto': impacto,
          'distrito': distrito,
        }),
      );
      final body = json.decode(response.body);
      return {
        'statusCode': response.statusCode,
        'message': body['message'] ?? 'Respuesta inesperada'
      };
    } catch (e) {
      print("Error en editarReporteAutor Service: $e");
      return {'statusCode': 500, 'message': 'Error de conexión.'};
    }
  }
} // Fin de la clase ReporteService