import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/estadisticas_model.dart';
import 'package:mobile_app/models/analiticas_reportero_model.dart'; // <-- IMPORTAR
import 'package:mobile_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnaliticasService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // --- Helper para peticiones GET genéricas ---
  Future<dynamic> _get(String endpoint) async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');

    final url = Uri.parse('${ApiConstants.baseUrl}/api/analiticas/$endpoint');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 403) {
        throw Exception('Acceso denegado. Requiere plan Reportero o Admin.');
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // --- Métodos Existentes ---
  Future<List<DatoGrafico>> getReportesPorCategoria() async {
    final List data = await _get('por-categoria');
    return data.map((json) => DatoGrafico.fromJson(json)).toList();
  }

  Future<List<DatoGrafico>> getReportesPorDistrito() async {
    final List data = await _get('por-distrito');
    return data.map((json) => DatoGrafico.fromJson(json)).toList();
  }

  Future<List<DatoGrafico>> getTendenciaReportes() async {
    final List data = await _get('tendencia');
    return data.map((json) => DatoGrafico.fromJson(json)).toList();
  }

  // --- NUEVOS MÉTODOS (Reportero) ---

  /// Obtiene la distribución de reportes por nivel de urgencia.
  Future<List<DatoGrafico>> getReportesPorUrgencia() async {
    final List data = await _get('por-urgencia');
    return data.map((json) => DatoGrafico.fromJson(json)).toList();
  }

  /// Obtiene las métricas de eficiencia de atención.
  Future<TiemposAtencion> getTiemposAtencion() async {
    final data = await _get('tiempos-atencion');
    return TiemposAtencion.fromJson(data);
  }

  /// Obtiene la lista de puntos para el mapa de calor.
  Future<List<PuntoMapaCalor>> getMapaCalor() async {
    final List data = await _get('mapa-calor');
    return data.map((json) => PuntoMapaCalor.fromJson(json)).toList();
  }
  
  // Método legacy para registro de PDF (opcional)
  Future<void> solicitarExportacionPDF() async {
     await _get('exportar-pdf'); // Usamos GET o POST según ruta, aquí simplificado
  }
}