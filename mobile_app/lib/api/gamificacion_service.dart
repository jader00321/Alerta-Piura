// lib/api/gamificacion_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/models/insignia_detalle_model.dart';

/// Gestiona las interacciones con el módulo de gamificación de la API.
///
/// Esta clase es responsable de obtener información sobre las insignias
/// y el progreso del usuario en el sistema.
class GamificacionService {
  /// Método privado para obtener el token de autenticación guardado localmente.
  ///
  /// Utiliza [SharedPreferences] para buscar el 'authToken'.
  /// Retorna el token como un [String], o [null] si no se encuentra.
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  /// Obtiene todas las insignias y el progreso del usuario.
  ///
  /// Realiza una petición GET al endpoint `/api/gamificacion/insignias`
  /// para obtener la lista de insignias disponibles y el estado
  /// actual del usuario (cuáles ha ganado y su progreso en otras).
  ///
  /// Retorna un objeto [ProgresoInsignias] si la petición es exitosa (código 200).
  ///
  /// Lanza una [Exception] en los siguientes casos:
  /// - Si el usuario no está autenticado (token nulo).
  /// - Si la API devuelve un código de estado diferente a 200.
  /// - Si ocurre un error de red o conexión (atrapado por `try-catch`).
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
      // Atrapa errores de red o timeouts
      throw Exception('Error de conexión al cargar insignias');
    }
  }
}