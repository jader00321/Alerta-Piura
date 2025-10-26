// lib/api/servicio_suscripcion.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/plan_suscripcion_model.dart';
import 'package:mobile_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServicioSuscripcion {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<List<PlanSuscripcion>> getPlanes() async {
    final token = await _getToken();
    if (token == null) throw Exception('Usuario no autenticado');

    final url = Uri.parse('${ApiConstants.baseUrl}/api/subscriptions/plans');
    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final List<dynamic> planesJson = json.decode(response.body);
        return planesJson
            .map((json) => PlanSuscripcion.fromJson(json))
            .toList();
      } else {
        throw Exception('Error al cargar los planes desde el servidor');
      }
    } catch (e) {
      throw Exception('Error de conexión al cargar los planes');
    }
  }

  // --- FUNCIÓN CORREGIDA ---
  /// Envía la solicitud de suscripción con un ID de plan y un payload de pago dinámico.
  Future<Map<String, dynamic>> suscribirseAlPlan(
      int planId, Map<String, dynamic> paymentPayload) async {
    final token = await _getToken();
    if (token == null) {
      return {
        'statusCode': 401,
        'data': {'message': 'Usuario no autenticado'}
      };
    }

    final url =
        Uri.parse('${ApiConstants.baseUrl}/api/subscriptions/subscribe');
    try {
      // The body now correctly includes the planId along with the payment payload
      final body = {
        'planId': planId,
        ...paymentPayload,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(body),
      );

      return {
        'statusCode': response.statusCode,
        'data': json.decode(response.body)
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'data': {'message': 'Error de conexión durante la suscripción'}
      };
    }
  }

  /// Envía la solicitud para cancelar la suscripción activa del usuario.
  Future<Map<String, dynamic>> cancelarSuscripcion() async {
    final token = await _getToken();
    if (token == null) {
      return {
        'statusCode': 401,
        'data': {'message': 'Usuario no autenticado'}
      };
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/api/subscriptions/cancel');
    try {
      final response = await http.put(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      return {
        'statusCode': response.statusCode,
        'data': json.decode(response.body)
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'data': {'message': 'Error de conexión'}
      };
    }
  }
}
