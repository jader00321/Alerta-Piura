// lib/api/analiticas_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/estadisticas_model.dart';
import 'package:mobile_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestiona la comunicación con la API de analíticas.
///
/// Esta clase se encarga de obtener datos estadísticos
/// para los gráficos de la aplicación, manejando la autenticación
/// y el procesamiento de las respuestas.
class AnaliticasService {
  /// Método privado para obtener el token de autenticación guardado localmente.
  ///
  /// Utiliza [SharedPreferences] para buscar el 'authToken'.
  /// Retorna el token como un [String], o [null] si no se encuentra.
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }
  /// Método genérico privado para realizar peticiones GET a los endpoints de analíticas.
  ///
  /// Se encarga de:
  /// 1. Obtener el token con [_getToken].
  /// 2. Construir la URL completa.
  /// 3. Añadir el token 'Bearer' a las cabeceras.
  /// 4. Decodificar la respuesta JSON y mapearla a una `List<DatoGrafico>`.
  ///
  /// Lanza una [Exception] si el token es nulo o si la API
  /// devuelve un código de estado diferente a 200.
  Future<List<DatoGrafico>> _fetchDatosGrafico(String endpoint) async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');

    final url = Uri.parse('${ApiConstants.baseUrl}/api/analiticas/$endpoint');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => DatoGrafico.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar datos de analíticas ($endpoint)');
    }
  }

  /// Obtiene las estadísticas de reportes agrupados por categoría.
  ///
  /// Llama a [_fetchDatosGrafico] con el endpoint 'por-categoria'.
  Future<List<DatoGrafico>> getReportesPorCategoria() {
    return _fetchDatosGrafico('por-categoria');
  }

  /// Obtiene las estadísticas de reportes agrupados por distrito.
  ///
  /// Llama a [_fetchDatosGrafico] con el endpoint 'por-distrito'.
  Future<List<DatoGrafico>> getReportesPorDistrito() {
    return _fetchDatosGrafico('por-distrito');
  }

  /// Obtiene la tendencia de reportes a lo largo del tiempo.
  ///
  /// Llama a [_fetchDatosGrafico] con el endpoint 'tendencia'.
  Future<List<DatoGrafico>> getTendenciaReportes() {
    return _fetchDatosGrafico('tendencia');
  }

  /// Registra una solicitud de exportación de PDF en el backend.
  ///
  /// Esta función realiza una petición POST al endpoint 'exportar-pdf'.
  ///
  /// **Nota:** Esta función ya no se usa para generar el PDF en el cliente,
  /// pero se mantiene para registrar la descarga en el backend.
  ///
  /// Retorna un [Map] con el [statusCode] de la respuesta y
  /// los [data] (JSON decodificado).
  Future<Map<String, dynamic>> solicitarExportacionPDF() async {
    final token = await _getToken();
    if (token == null) return {'statusCode': 401, 'data': {'message': 'No autenticado'}};

    final url = Uri.parse('${ApiConstants.baseUrl}/api/analiticas/exportar-pdf');
    final response = await http.post(url, headers: {'Authorization': 'Bearer $token'});

    return {'statusCode': response.statusCode, 'data': json.decode(response.body)};
  }
}