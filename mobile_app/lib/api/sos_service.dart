import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SosService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // --- UPDATED to include emergencyContact ---
  Future<int?> activateSos({
    required double lat, 
    required double lon,
    Map<String, String?>? emergencyContact,
  }) async {
    final token = await _getToken();
    if (token == null) return null;
    
    final url = Uri.parse(ApiConstants.baseUrl + '/api/sos/activate');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        // Send all data in the body
        body: json.encode({
          'lat': lat, 
          'lon': lon,
          'emergencyContact': emergencyContact,
        }),
      );
      if (response.statusCode == 201) {
        return json.decode(response.body)['alert']['id'];
      }
    } catch (e) {
      print('Error activating SOS: $e');
    }
    return null;
  }

  Future<void> addLocationUpdate({required int alertId, required double lat, required double lon}) async {
    final token = await _getToken();
    if (token == null) return;

    final url = Uri.parse(ApiConstants.baseUrl + '/api/sos/$alertId/location');
    try {
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'lat': lat, 'lon': lon}),
      );
    } catch (e) {
      print('Error sending location update: $e');
    }
  }
}