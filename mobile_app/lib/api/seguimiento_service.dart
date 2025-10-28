import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/reporte_resumen_model.dart'; // <-- Usar ReporteResumen
import 'package:mobile_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestiona la funcionalidad de "seguir" y "dejar de seguir" reportes.
///
/// Permite al usuario suscribirse a las actualizaciones de reportes específicos
/// y consultar la lista de reportes que está siguiendo.
class SeguimientoService {
  /// Método privado para obtener el token de autenticación guardado localmente.
  ///
  /// Utiliza [SharedPreferences] para buscar el 'authToken'.
  /// Retorna el token como un [String], o [null] si no se encuentra.
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  /// Verifica si el usuario actual está siguiendo un reporte específico.
  ///
  /// [idReporte]: El ID del reporte que se desea verificar.
  ///
  /// Retorna `true` si el usuario está siguiendo el reporte (API devuelve 200 y 'siguiendo': true).
  /// Retorna `false` si no lo está siguiendo, si no está autenticado o si ocurre un error.
  Future<bool> verificarSeguimiento(int idReporte) async {
    final token = await _getToken();
    if (token == null) return false;
    final url = Uri.parse(
        '${ApiConstants.baseUrl}/api/seguimiento/reporte/$idReporte/verificar');
    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        return json.decode(response.body)['siguiendo'];
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Permite al usuario autenticado "seguir" un reporte.
  ///
  /// [idReporte]: El ID del reporte que se desea seguir.
  ///
  /// Retorna `true` si la operación es exitosa (código 201).
  /// Retorna `false` si el usuario no está autenticado o si la API devuelve otro estado.
  Future<bool> seguirReporte(int idReporte) async {
    final token = await _getToken();
    if (token == null) return false;
    final url = Uri.parse(
        '${ApiConstants.baseUrl}/api/seguimiento/reporte/$idReporte/seguir');
    final response =
        await http.post(url, headers: {'Authorization': 'Bearer $token'});
    return response.statusCode == 201;
  }

  /// Permite al usuario autenticado "dejar de seguir" un reporte.
  ///
  /// [idReporte]: El ID del reporte que se desea dejar de seguir.
  ///
  /// Retorna `true` si la operación es exitosa (código 200).
  /// Retorna `false` si el usuario no está autenticado o si la API devuelve otro estado.
  Future<bool> dejarDeSeguirReporte(int idReporte) async {
    final token = await _getToken();
    if (token == null) return false;
    final url = Uri.parse(
        '${ApiConstants.baseUrl}/api/seguimiento/reporte/$idReporte/dejar-de-seguir');
    final response =
        await http.delete(url, headers: {'Authorization': 'Bearer $token'});
    return response.statusCode == 200;
  }

  /// Obtiene la lista de reportes que el usuario actual está siguiendo.
  ///
  /// Consulta el endpoint `/api/seguimiento/mis-seguimientos`.
  ///
  /// Retorna una `List<ReporteResumen>` con los datos de los reportes seguidos.
  ///
  /// Lanza una [Exception] si el usuario no está autenticado,
  /// si la API devuelve un error, o si hay un problema de conexión.
  Future<List<ReporteResumen>> getMisReportesSeguidos() async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');
    final url =
        Uri.parse('${ApiConstants.baseUrl}/api/seguimiento/mis-seguimientos');
    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final List<dynamic> reportesJson = json.decode(response.body);
        // Mapear al modelo ReporteResumen actualizado
        return reportesJson
            .map((json) => ReporteResumen.fromJson(json))
            .toList();
      } else {
        throw Exception('Error al cargar reportes seguidos');
      }
    } catch (e) {
      print("Error fetching followed reports: $e");
      throw Exception('Error de conexión al cargar seguidos.');
    }
  }
}