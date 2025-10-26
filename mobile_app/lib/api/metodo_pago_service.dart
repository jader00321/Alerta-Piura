import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/metodo_pago_model.dart';
import 'package:mobile_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MetodoPagoService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<List<MetodoPago>> listarMetodos() async {
    final token = await _getToken();
    if (token == null) throw Exception('No autenticado');
    final url = Uri.parse('${ApiConstants.baseUrl}/api/metodos-pago');
    final response =
        await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((m) => MetodoPago.fromJson(m)).toList();
    } else {
      throw Exception('Error al cargar métodos de pago');
    }
  }

  Future<bool> crearMetodo(Map<String, dynamic> datosTarjeta) async {
    final token = await _getToken();
    if (token == null) return false;
    final url = Uri.parse('${ApiConstants.baseUrl}/api/metodos-pago');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode(datosTarjeta),
    );
    return response.statusCode == 201;
  }

  Future<bool> establecerPredeterminado(int idMetodo) async {
    final token = await _getToken();
    if (token == null) return false;
    final url = Uri.parse(
        '${ApiConstants.baseUrl}/api/metodos-pago/$idMetodo/predeterminado');
    final response =
        await http.put(url, headers: {'Authorization': 'Bearer $token'});
    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> eliminarMetodo(int idMetodo) async {
    final token = await _getToken();
    if (token == null) return {'statusCode': 401, 'message': 'No autenticado'};

    final url = Uri.parse('${ApiConstants.baseUrl}/api/metodos-pago/$idMetodo');
    final response =
        await http.delete(url, headers: {'Authorization': 'Bearer $token'});

    return {
      'statusCode': response.statusCode,
      'message': json.decode(response.body)['message']
    };
  }
}
