import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Para debugPrint

/// Gestiona la funcionalidad de alertas SOS.
class SosService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  /// Activa una nueva alerta SOS.
  /// [token]: Token JWT opcional (usado por Background Service).
  Future<int> activateSos({
    required double lat,
    required double lon,
    required int durationInSeconds,
    Map<String, dynamic>? emergencyContact,
    String? token, // <--- NUEVO PARÁMETRO
  }) async {
    // Si no nos dan token, lo buscamos (comportamiento normal de UI)
    // Si nos dan token (Background Service), usamos ese.
    final authToken = token ?? await _getToken();
    
    if (authToken == null) {
      debugPrint("SOS API: No hay token.");
      return 0;
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/api/sos/activate');
    
    try {
      final bodyData = {
        'lat': lat,
        'lon': lon,
        'durationInSeconds': durationInSeconds,
        // Aseguramos enviar el contacto si existe
        if (emergencyContact != null) 'emergencyContact': emergencyContact,
      };

      debugPrint("SOS API: Enviando activación... $bodyData");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken', // Usar la variable local
        },
        body: json.encode(bodyData),
      );

      debugPrint("SOS API: Respuesta ${response.statusCode} - ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Manejo robusto: Buscar 'alertId', 'id' o devolver 0
        if (data['alertId'] != null) {
          return int.parse(data['alertId'].toString());
        } else if (data['id'] != null) {
          return int.parse(data['id'].toString());
        }
      }
      
      return 0;
    } catch (e) {
      debugPrint('SOS API Error: $e');
      return 0;
    }
  }

  /// Envía actualización de ubicación.
  Future<bool> addLocationUpdate({
    required int alertId,
    required double lat,
    required double lon,
    String? token,
  }) async {
    final authToken = token ?? await _getToken();
    if (authToken == null) return false;

    final url = Uri.parse('${ApiConstants.baseUrl}/api/sos/$alertId/location');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({'lat': lat, 'lon': lon}),
      );
      return response.statusCode == 200;
    } catch (e) {
      // debugPrint('SOS API: Error location update: $e');
      return false;
    }
  }

  /// Desactiva manualmente la alerta.
  Future<bool> deactivateSos(int alertId) async {
    final token = await _getToken();
    if (token == null) return false;

    final url = Uri.parse('${ApiConstants.baseUrl}/api/sos/$alertId/deactivate');
    try {
      final response = await http.put(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      debugPrint("SOS API: Desactivar respuesta ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('SOS API: Error deactivate: $e');
      return false;
    }
  }
}