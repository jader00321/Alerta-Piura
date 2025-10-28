// lib/api/sos_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestiona la funcionalidad de alertas SOS.
///
/// Proporciona métodos para activar una nueva alerta de emergencia,
/// enviar actualizaciones de ubicación durante la alerta y
/// desactivarla manualmente.
class SosService {
  /// Método privado para obtener el token de autenticación guardado localmente.
  ///
  /// Utiliza [SharedPreferences] para buscar el 'authToken'.
  /// Retorna el token como un [String], o [null] si no se encuentra.
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  /// Activa una nueva alerta SOS en el sistema.
  ///
  /// Envía la ubicación inicial del usuario, un contacto de emergencia opcional
  /// y la duración deseada de la alerta.
  ///
  /// - [lat]: Latitud actual del usuario.
  /// - [lon]: Longitud actual del usuario.
  /// - [emergencyContact]: (Opcional) Un [Map] con 'nombre' y 'telefono'
  ///   del contacto de emergencia.
  /// - [durationInSeconds]: El tiempo que la alerta permanecerá activa
  ///   recibiendo actualizaciones.
  ///
  /// Retorna el `alertId` (un [int]) si la alerta se crea exitosamente (código 201).
  /// Retorna `null` si el usuario no está autenticado, si la API falla,
  /// o si ocurre un error de conexión.
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

      // Si es exitoso, leer el ID de la alerta devuelta
      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        // Devolvemos el ID de la alerta creada
        return responseData['alert']['id'];
      }
    } catch (e) {
      print('Error al activar SOS: $e');
    }
    return null; // Retorna null si falla
  }

  /// Envía una actualización de ubicación para una alerta SOS activa.
  ///
  /// [alertId]: El ID de la alerta activa (obtenido de [activateSos]).
  /// [lat]: La nueva latitud del usuario.
  /// [lon]: La nueva longitud del usuario.
  ///
  /// Retorna `true` si la actualización se registra exitosamente (código 200).
  /// Retorna `false` en cualquier otro caso.
  Future<bool> addLocationUpdate(
      {required int alertId,
      required double lat,
      required double lon}) async {
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

  /// Desactiva manualmente una alerta SOS activa.
  ///
  /// [alertId]: El ID de la alerta que se desea desactivar.
  ///
  /// Retorna `true` si la desactivación es exitosa (código 200).
  /// Retorna `false` en cualquier otro caso.
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