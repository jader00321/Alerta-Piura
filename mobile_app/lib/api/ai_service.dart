import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  /// Envía el texto actual al backend para ser mejorado por Gemini.
  /// Retorna el texto mejorado o null si falla.
  Future<String?> improveReportDescription(String currentText) async {
    final token = await _getToken();
    if (token == null) return null;

    final url = Uri.parse('${ApiConstants.baseUrl}/api/ai/enhance');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'text': currentText}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['enhanced'];
      } else {
        print("AI Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("AI Connection Error: $e");
      return null;
    }
  }
}