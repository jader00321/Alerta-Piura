// lib/api/sos_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SosService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // --- FUNCIÓN MODIFICADA ---
  Future<int?> activateSos({
    required double lat, 
    required double lon,
    Map<String, String?>? emergencyContact,
    required int durationInSeconds, 
  }) async {
    final token = await _getToken();
    if (token == null) return null;
    
    final url = Uri.parse('${ApiConstants.baseUrl}/api/sos/activate');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'lat': lat, 
          'lon': lon,
          'emergencyContact': emergencyContact, // Enviar el mapa de contacto
          'durationInSeconds': durationInSeconds, // Enviar la duración
        }),
      );
      
      // --- MODIFICADO: Leer el ID de la alerta devuelta ---
      if (response.statusCode == 201) {
        // El backend ahora devuelve { message: '...', alert: {...} }
        final responseData = json.decode(response.body);
        // Devolvemos el ID de la alerta creada
        return responseData['alert']['id'];
      }
    } catch (e) {
      print('Error al activar SOS: $e');
    }
    return null; // Retorna null si falla
  }

  Future<bool> addLocationUpdate({required int alertId, required double lat, required double lon}) async {
    final token = await _getToken();
    if (token == null) return false;

    final url = Uri.parse('${ApiConstants.baseUrl}/api/sos/$alertId/location');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'lat': lat, 'lon': lon}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error al enviar actualización de ubicación: $e');
      return false;
    }
  }

  Future<bool> deactivateSos(int alertId) async {
    final token = await _getToken();
    if (token == null) return false;

    final url = Uri.parse('${ApiConstants.baseUrl}/api/sos/$alertId/deactivate');
    try {
      final response = await http.put(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error al desactivar SOS: $e');
      return false;
    }
  }
}