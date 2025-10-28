// lib/api/servicio_suscripcion.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/plan_suscripcion_model.dart';
import 'package:mobile_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestiona la obtención de planes de suscripción y el estado de la suscripción del usuario.
///
/// Permite consultar planes, crear una nueva suscripción y cancelarla.
class ServicioSuscripcion {
  /// Método privado para obtener el token de autenticación guardado localmente.
  ///
  /// Utiliza [SharedPreferences] para buscar el 'authToken'.
  /// Retorna el token como un [String], o [null] si no se encuentra.
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  /// Obtiene la lista de planes de suscripción disponibles.
  ///
  /// Consulta el endpoint `/api/subscriptions/plans`.
  /// Retorna una `List<PlanSuscripcion>`.
  ///
  /// Lanza una [Exception] si el usuario no está autenticado, si la API
  /// devuelve un error o si hay un problema de conexión.
  Future<List<PlanSuscripcion>> getPlanes() async {
    final token = await _getToken();
    if (token == null) throw Exception('Usuario no autenticado');

    final url = Uri.parse('${ApiConstants.baseUrl}/api/subscriptions/plans');
    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final List<dynamic> planesJson = json.decode(response.body);
        return planesJson.map((json) => PlanSuscripcion.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar los planes desde el servidor');
      }
    } catch (e) {
      throw Exception('Error de conexión al cargar los planes');
    }
  }

  /// Envía la solicitud de suscripción con un ID de plan y un payload de pago dinámico.
  ///
  /// [planId]: El ID del plan al que se desea suscribir.
  /// [paymentPayload]: Un [Map] que contiene los detalles del pago
  /// (ej. el ID del método de pago o el token de la pasarela).
  ///
  /// Retorna un [Map] con `statusCode` y `data` (JSON decodificado).
  /// Maneja errores 401 (No autenticado) y 500 (Error de conexión).
  Future<Map<String, dynamic>> suscribirseAlPlan(
      int planId, Map<String, dynamic> paymentPayload) async {
    final token = await _getToken();
    if (token == null) {
      return {'statusCode': 401, 'data': {'message': 'Usuario no autenticado'}};
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/api/subscriptions/subscribe');
    try {
      // El cuerpo incluye el planId junto con el payload de pago.
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

      return {'statusCode': response.statusCode, 'data': json.decode(response.body)};
    } catch (e) {
      return {
        'statusCode': 500,
        'data': {'message': 'Error de conexión durante la suscripción'}
      };
    }
  }

  /// Envía la solicitud para cancelar la suscripción activa del usuario.
  ///
  /// Consulta el endpoint `/api/subscriptions/cancel` (vía PUT).
  ///
  /// Retorna un [Map] con `statusCode` y `data` (JSON decodificado).
  /// Maneja errores 401 (No autenticado) y 500 (Error de conexión).
  Future<Map<String, dynamic>> cancelarSuscripcion() async {
    final token = await _getToken();
    if (token == null) {
      return {'statusCode': 401, 'data': {'message': 'Usuario no autenticado'}};
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/api/subscriptions/cancel');
    try {
      final response = await http.put(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      return {'statusCode': response.statusCode, 'data': json.decode(response.body)};
    } catch (e) {
      return {'statusCode': 500, 'data': {'message': 'Error de conexión'}};
    }
  }
}