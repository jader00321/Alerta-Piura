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

/// Gestiona todas las operaciones relacionadas con el perfil del usuario.
///
/// Incluye la obtención y actualización de datos personales, gestión de
/// actividad (reportes, apoyos), notificaciones, historial de pagos,
/// zonas seguras, estadísticas y postulación a líder.
class PerfilService {
  /// Método privado para obtener el token de autenticación guardado localmente.
  ///
  /// Utiliza [SharedPreferences] para buscar el 'authToken'.
  /// Retorna el token como un [String], o [null] si no se encuentra.
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  /// Obtiene los datos completos del perfil del usuario, incluyendo insignias.
  ///
  /// Consulta el endpoint `/api/perfil/me`.
  /// Retorna un objeto [Perfil] con los datos del usuario.
  ///
  /// Lanza una [Exception] si el usuario no está autenticado,
  /// si la API devuelve un error o si hay un problema de conexión.
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

  /// Función genérica privada para obtener listas de actividad del usuario.
  ///
  /// [endpoint]: La ruta de la API a consultar (ej. '/api/perfil/me/reportes').
  /// Retorna una `List<ReporteResumen>`.
  ///
  /// Lanza una [Exception] si el token es nulo, si la API devuelve
  /// un error o si hay un problema de conexión.
  Future<List<ReporteResumen>> _fetchReportList(String endpoint) async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');

    final url = Uri.parse(ApiConstants.baseUrl + endpoint);
    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((item) => ReporteResumen.fromJson(item))
            .toList();
      } else {
        throw Exception('Error del servidor al cargar la lista');
      }
    } catch (e) {
      throw Exception('Error de conexión');
    }
  }

  /// Obtiene los reportes creados por el usuario.
  ///
  /// Utiliza [_fetchReportList] con el endpoint `/api/perfil/me/reportes`.
  Future<List<ReporteResumen>> getMisReportes() {
    return _fetchReportList('/api/perfil/me/reportes');
  }

  /// Obtiene los reportes que el usuario ha apoyado.
  ///
  /// Utiliza [_fetchReportList] con el endpoint `/api/perfil/me/apoyos`.
  Future<List<ReporteResumen>> getMisApoyos() {
    return _fetchReportList('/api/perfil/me/apoyos');
  }

  /// Obtiene los reportes en los que el usuario ha comentado.
  ///
  /// Utiliza [_fetchReportList] con el endpoint `/api/perfil/me/comentarios`.
  Future<List<ReporteResumen>> getMisComentarios() {
    return _fetchReportList('/api/perfil/me/comentarios');
  }

  /// Obtiene las conversaciones activas (chats) del usuario (para líderes).
  ///
  /// Consulta el endpoint `/api/perfil/me/conversaciones`.
  /// Retorna una `List<Conversacion>`.
  ///
  /// Lanza una [Exception] si el token es nulo o si la API devuelve un error.
  Future<List<Conversacion>> getMisConversaciones() async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');

    final url =
        Uri.parse('${ApiConstants.baseUrl}/api/perfil/me/conversaciones');
    final response =
        await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((c) => Conversacion.fromJson(c)).toList();
    } else {
      throw Exception('Error al cargar conversaciones');
    }
  }

  /// Obtiene el historial de notificaciones del usuario.
  ///
  /// Consulta el endpoint `/api/perfil/me/notificaciones`.
  /// Retorna una `List<Notificacion>`.
  ///
  /// Lanza una [Exception] si el token es nulo, si la API devuelve
  /// un error o si hay un problema de conexión.
  Future<List<Notificacion>> getMisNotificaciones() async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');

    final url =
        Uri.parse('${ApiConstants.baseUrl}/api/perfil/me/notificaciones');
    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});
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
  ///
  /// [nombre]: El nuevo nombre completo.
  /// [alias]: (Opcional) El nuevo apodo.
  /// [telefono]: (Opcional) El nuevo número de teléfono.
  ///
  /// Retorna `true` si la actualización es exitosa (código 200).
  /// Retorna `false` si el token es nulo o si la API devuelve otro estado.
  Future<bool> updateMyProfile(
      String nombre, String? alias, String? telefono) async {
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
  ///
  /// [currentPassword]: La contraseña actual del usuario.
  /// [newPassword]: La nueva contraseña deseada.
  ///
  /// Retorna un [Map] con `statusCode` y `data` (JSON decodificado)
  /// de la respuesta de la API.
  Future<Map<String, dynamic>> updateMyPassword(
      String currentPassword, String newPassword) async {
    final token = await _getToken();
    if (token == null)
      return {'statusCode': 401, 'data': {'message': 'No autenticado'}};

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

  /// Actualiza el correo electrónico del usuario.
  ///
  /// [newEmail]: El nuevo correo electrónico deseado.
  /// [password]: La contraseña actual del usuario para verificación.
  ///
  /// Retorna un [Map] con `statusCode` y `data` (JSON decodificado)
  /// de la respuesta de la API.
  Future<Map<String, dynamic>> updateMyEmail(
      String newEmail, String password) async {
    final token = await _getToken();
    final url = Uri.parse(ApiConstants.baseUrl + '/api/perfil/me/email');
    final response = await http.put(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({'newEmail': newEmail, 'password': password}));
    return {'statusCode': response.statusCode, 'data': json.decode(response.body)};
  }

  /// Verifica la contraseña actual del usuario.
  ///
  /// [password]: La contraseña a verificar.
  ///
  /// Retorna `true` si la contraseña es correcta (código 200).
  /// Retorna `false` en cualquier otro caso.
  Future<bool> verifyPassword(String password) async {
    final token = await _getToken();
    if (token == null) return false;
    final url = Uri.parse(ApiConstants.baseUrl + '/api/auth/verify-password');
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({'password': password}));
    return response.statusCode == 200;
  }

  /// Marca todas las notificaciones del usuario como leídas.
  ///
  /// Retorna `true` si la operación es exitosa (código 200).
  /// Retorna `false` en cualquier otro caso.
  Future<bool> marcarTodasComoLeidas() async {
    final token = await _getToken();
    if (token == null) return false;

    final url = Uri.parse(
        '${ApiConstants.baseUrl}/api/perfil/me/notificaciones/mark-all-read');
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
  ///
  /// Consulta el endpoint `/api/perfil/me/payment-history`.
  /// Retorna una `List<HistorialPago>`.
  ///
  /// Lanza una [Exception] si el token es nulo, si la API devuelve
  /// un error o si hay un problema de conexión.
  Future<List<HistorialPago>> getHistorialPagos() async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');

    final url =
        Uri.parse('${ApiConstants.baseUrl}/api/perfil/me/payment-history');
    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((item) => HistorialPago.fromJson(item))
            .toList();
      } else {
        throw Exception('Error del servidor al cargar el historial de pagos');
      }
    } catch (e) {
      throw Exception('Error de conexión');
    }
  }

  /// Obtiene los detalles completos de una boleta de pago específica.
  ///
  /// [transactionId]: El identificador único de la transacción (boleta).
  /// Retorna un objeto [BoletaDetalle].
  ///
  /// Lanza una [Exception] si el token es nulo, si la API devuelve
  /// un error o si hay un problema de conexión.
  Future<BoletaDetalle> getDetalleBoleta(String transactionId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');

    final url = Uri.parse(
        '${ApiConstants.baseUrl}/api/perfil/me/invoices/$transactionId');
    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        return BoletaDetalle.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error del servidor al cargar los detalles de la boleta');
      }
    } catch (e) {
      throw Exception('Error de conexión');
    }
  }

  /// Obtiene un resumen de las estadísticas del usuario (reportes, apoyos, insignias).
  ///
  /// Retorna un objeto [EstadisticasResumen].
  /// Lanza una [Exception] si el token es nulo o si la API falla.
  Future<EstadisticasResumen> getMisEstadisticasResumen() async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');
    final url = Uri.parse(
        '${ApiConstants.baseUrl}/api/perfil/me/estadisticas/resumen');
    final response =
        await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      return EstadisticasResumen.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al cargar resumen de estadísticas');
    }
  }

  /// Obtiene los datos para el gráfico de reportes por categoría del usuario.
  ///
  /// Retorna una `List<DatoGrafico>`.
  /// Lanza una [Exception] si el token es nulo o si la API falla.
  Future<List<DatoGrafico>> getMisReportesPorCategoria() async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');
    final url = Uri.parse(
        '${ApiConstants.baseUrl}/api/perfil/me/estadisticas/por-categoria');
    final response =
        await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => DatoGrafico.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar datos por categoría');
    }
  }

  /// Obtiene la lista de zonas seguras del usuario.
  ///
  /// Retorna una `List<ZonaSegura>`.
  /// Lanza una [Exception] si el token es nulo o si la API falla.
  Future<List<ZonaSegura>> getMisZonasSeguras() async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');
    final url =
        Uri.parse('${ApiConstants.baseUrl}/api/perfil/me/zonas-seguras');
    final response =
        await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((zona) => ZonaSegura.fromJson(zona)).toList();
    } else {
      throw Exception('Error al cargar las zonas seguras');
    }
  }

  /// Crea una nueva zona segura para el usuario.
  ///
  /// [nombre]: Nombre descriptivo para la zona.
  /// [centro]: Coordenadas [LatLng] del centro de la zona.
  /// [radio]: El radio de la zona en metros.
  ///
  /// Retorna `true` si se crea exitosamente (código 201).
  /// Retorna `false` en cualquier otro caso.
  Future<bool> crearZonaSegura({
    required String nombre,
    required LatLng centro,
    required int radio,
  }) async {
    final token = await _getToken();
    if (token == null) return false;
    final url =
        Uri.parse('${ApiConstants.baseUrl}/api/perfil/me/zonas-seguras');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
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
  ///
  /// [idZona]: El ID de la zona a eliminar.
  ///
  /// Retorna `true` si se elimina exitosamente (código 200).
  /// Retorna `false` en cualquier otro caso.
  Future<bool> eliminarZonaSegura(int idZona) async {
    final token = await _getToken();
    if (token == null) return false;
    final url = Uri.parse(
        '${ApiConstants.baseUrl}/api/perfil/me/zonas-seguras/$idZona');
    final response =
        await http.delete(url, headers: {'Authorization': 'Bearer $token'});
    return response.statusCode == 200;
  }

  /// Envía una postulación para convertirse en líder.
  ///
  /// [motivacion]: Texto explicando la motivación del usuario.
  /// [zonaPropuesta]: La zona o distrito que el usuario propone liderar.
  ///
  /// Retorna un [Map] con `statusCode` y `message` de la API.
  Future<Map<String, dynamic>> postularComoLider({
    required String motivacion,
    required String zonaPropuesta,
  }) async {
    final token = await _getToken();
    if (token == null)
      return {'statusCode': 401, 'message': 'No autenticado'};

    final url = Uri.parse('${ApiConstants.baseUrl}/api/perfil/postular-lider');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({
          'motivacion': motivacion,
          'zona_propuesta': zonaPropuesta,
        }),
      );
      // Devolver status code y mensaje del body
      return {
        'statusCode': response.statusCode,
        'message':
            json.decode(response.body)['message'] ?? 'Respuesta inesperada'
      };
    } catch (e) {
      print("Error en postularComoLider: $e");
      return {'statusCode': 500, 'message': 'Error de conexión.'};
    }
  }

  /// Obtiene estadísticas de actividad del usuario (reportes creados, apoyos, comentarios).
  ///
  /// Retorna un [Map<String, int>] con los conteos.
  /// Lanza una [Exception] si el token es nulo, si la API falla o si hay
  /// un error de conexión.
  Future<Map<String, int>> getStatsActividad() async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');
    final url =
        Uri.parse('${ApiConstants.baseUrl}/api/perfil/me/stats/actividad');
    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data.map(
            (key, value) => MapEntry(key, (value is num) ? value.toInt() : 0));
      } else {
        throw Exception('Error al cargar estadísticas de actividad');
      }
    } catch (e) {
      print("Error fetching activity stats: $e");
      throw Exception('Error de conexión al cargar estadísticas.');
    }
  }

  /// Reporta a otro usuario en el sistema.
  ///
  /// [userIdToReport]: El ID del usuario que será reportado.
  /// [motivo]: La justificación del reporte.
  ///
  /// Retorna un [Map] con `statusCode` y `message` de la API.
  Future<Map<String, dynamic>> reportarUsuario(
      int userIdToReport, String motivo) async {
    final token = await _getToken();
    if (token == null)
      return {'statusCode': 401, 'message': 'No autenticado'};

    // Usa la ruta definida en usuarios.routes.js
    final url =
        Uri.parse('${ApiConstants.baseUrl}/api/usuarios/$userIdToReport/reportar');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({'motivo': motivo}),
      );
      // Devolver status code y mensaje del body
      return {
        'statusCode': response.statusCode,
        'message':
            json.decode(response.body)['message'] ?? 'Respuesta inesperada'
      };
    } catch (e) {
      print("Error en reportarUsuario Service: $e");
      return {'statusCode': 500, 'message': 'Error de conexión.'};
    }
  }
}