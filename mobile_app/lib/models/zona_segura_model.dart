import 'package:latlong2/latlong.dart';

/// Representa una zona segura (geocerca) definida por el usuario.
///
/// Este modelo se usa para almacenar las zonas de interés del usuario,
/// como "Casa" o "Trabajo", para recibir notificaciones de
/// incidentes que ocurran dentro de su radio.
class ZonaSegura {
  /// El ID único de la zona segura.
  final int id;

  /// El nombre personalizado que el usuario le dio a la zona (ej. "Casa").
  final String nombre;

  /// El radio de la zona en metros.
  final int radioMetros;

  /// Las coordenadas [LatLng] del centro de la zona.
  final LatLng centro;

  /// Crea una instancia de [ZonaSegura].
  ZonaSegura({
    required this.id,
    required this.nombre,
    required this.radioMetros,
    required this.centro,
  });

  /// Crea una instancia de [ZonaSegura] a partir de un mapa JSON.
  ///
  /// Este factory es utilizado para deserializar la respuesta de la API.
  /// Parsea [lat] y [lon] en un objeto [LatLng].
  factory ZonaSegura.fromJson(Map<String, dynamic> json) {
    return ZonaSegura(
      id: json['id'],
      nombre: json['nombre'],
      radioMetros: json['radio_metros'],
      centro: LatLng(json['lat'], json['lon']),
    );
  }
}