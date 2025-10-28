import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/metodo_pago_model.dart';
import 'package:mobile_app/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestiona las operaciones CRUD (Crear, Leer, Actualizar, Eliminar)
/// para los métodos de pago del usuario en la API.
class MetodoPagoService {
  /// Método privado para obtener el token de autenticación guardado localmente.
  ///
  /// Utiliza [SharedPreferences] para buscar el 'authToken'.
  /// Retorna el token como un [String], o [null] si no se encuentra.
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  /// Obtiene la lista de métodos de pago guardados por el usuario.
  ///
  /// Lanza una [Exception] si el usuario no está autenticado o si
  /// la API devuelve un error.
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

  /// Registra un nuevo método de pago (tarjeta) para el usuario.
  ///
  /// [datosTarjeta] debe ser un [Map] que contenga la información
  /// requerida por la API (ej. token de la pasarela de pago).
  ///
  /// Retorna `true` si se crea exitosamente (código 201).
  /// Retorna `false` si el token es nulo o si la API devuelve otro estado.
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

  /// Establece un método de pago como predeterminado para futuras compras.
  ///
  /// [idMetodo]: El ID del método de pago que se marcará como predeterminado.
  ///
  /// Retorna `true` si la operación es exitosa (código 200).
  /// Retorna `false` si el token es nulo o si la API devuelve otro estado.
  Future<bool> establecerPredeterminado(int idMetodo) async {
    final token = await _getToken();
    if (token == null) return false;
    final url = Uri.parse(
        '${ApiConstants.baseUrl}/api/metodos-pago/$idMetodo/predeterminado');
    final response =
        await http.put(url, headers: {'Authorization': 'Bearer $token'});
    return response.statusCode == 200;
  }

  /// Elimina un método de pago de la cuenta del usuario.
  ///
  /// [idMetodo]: El ID del método de pago a eliminar.
  ///
  /// Retorna un [Map] con el `statusCode` de la respuesta y un `message`.
  Future<Map<String, dynamic>> eliminarMetodo(int idMetodo) async {
    final token = await _getToken();
    if (token == null)
      return {'statusCode': 401, 'message': 'No autenticado'};

    final url = Uri.parse('${ApiConstants.baseUrl}/api/metodos-pago/$idMetodo');
    final response =
        await http.delete(url, headers: {'Authorization': 'Bearer $token'});

    return {
      'statusCode': response.statusCode,
      'message': json.decode(response.body)['message']
    };
  }
}