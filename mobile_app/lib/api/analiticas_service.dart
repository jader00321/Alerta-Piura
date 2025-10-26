// lib/api/analiticas_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/estadisticas_model.dart';
import 'package:mobile_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnaliticasService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<List<DatoGrafico>> _fetchDatosGrafico(String endpoint) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No autenticado');
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/api/analiticas/$endpoint');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => DatoGrafico.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar datos de analíticas ($endpoint)');
    }
  }

  Future<List<DatoGrafico>> getReportesPorCategoria() {
    return _fetchDatosGrafico('por-categoria');
  }

  Future<List<DatoGrafico>> getReportesPorDistrito() {
    return _fetchDatosGrafico('por-distrito');
  }

  Future<List<DatoGrafico>> getTendenciaReportes() {
    return _fetchDatosGrafico('tendencia');
  }

  Future<Map<String, dynamic>> solicitarExportacionPDF() async {
    final token = await _getToken();
    // --- CORRECCIÓN: Añadidas llaves {} ---
    if (token == null) {
      return {'statusCode': 401, 'data': {'message': 'No autenticado'}};
    }
    // --- FIN CORRECCIÓN ---

    final url = Uri.parse('${ApiConstants.baseUrl}/api/analiticas/exportar-pdf');
    final response = await http.post(url, headers: {'Authorization': 'Bearer $token'});

    return {'statusCode': response.statusCode, 'data': json.decode(response.body)};
  }
}