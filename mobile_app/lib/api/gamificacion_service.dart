// lib/api/gamificacion_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/models/insignia_detalle_model.dart';

class GamificacionService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  /// Obtiene todas las insignias y el progreso del usuario.
  Future<ProgresoInsignias> getProgresoInsignias() async {
    final token = await _getToken();
    if (token == null) throw Exception('Usuario no autenticado');

    final url = Uri.parse('${ApiConstants.baseUrl}/api/gamificacion/insignias');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return ProgresoInsignias.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al cargar el progreso de insignias');
      }
    } catch (e) {
      throw Exception('Error de conexión al cargar insignias');
    }
  }
}
