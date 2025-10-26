import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/reporte_resumen_model.dart';
import 'package:mobile_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SeguimientoService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<bool> verificarSeguimiento(int idReporte) async {
    final token = await _getToken();
    if (token == null) {
      return false;
    }
    final url = Uri.parse('${ApiConstants.baseUrl}/api/seguimiento/reporte/$idReporte/verificar');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        return json.decode(response.body)['siguiendo'];
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> seguirReporte(int idReporte) async {
    final token = await _getToken();
    if (token == null) {
      return false;
    }
    final url = Uri.parse('${ApiConstants.baseUrl}/api/seguimiento/reporte/$idReporte/seguir');
    final response = await http.post(url, headers: {'Authorization': 'Bearer $token'});
    return response.statusCode == 201;
  }

  Future<bool> dejarDeSeguirReporte(int idReporte) async {
    final token = await _getToken();
    if (token == null) {
      return false;
    }
    final url = Uri.parse('${ApiConstants.baseUrl}/api/seguimiento/reporte/$idReporte/dejar-de-seguir');
    final response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});
    return response.statusCode == 200;
  }

  Future<List<ReporteResumen>> getMisReportesSeguidos() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No autenticado');
    }
    final url = Uri.parse('${ApiConstants.baseUrl}/api/seguimiento/mis-seguimientos');
    try {
        final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
        if (response.statusCode == 200) {
          final List<dynamic> reportesJson = json.decode(response.body);
          return reportesJson.map((jsonMap) => ReporteResumen.fromJson(jsonMap)).toList();
        } else {
          throw Exception('Error al cargar reportes seguidos');
        }
    } catch (e) {
        debugPrint("Error fetching followed reports: $e");
        throw Exception('Error de conexión al cargar seguidos.');
    }
  }
}