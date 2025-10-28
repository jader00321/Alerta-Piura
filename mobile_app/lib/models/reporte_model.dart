import 'package:latlong2/latlong.dart';

/// Representa un reporte en su forma más básica.
///
/// Este modelo se utiliza para mostrar los reportes como marcadores
/// en el mapa principal, conteniendo solo la información esencial
/// para la visualización (ID, título, ubicación y prioridad).
class Reporte {
  /// El ID único del reporte.
  final int id;

  /// El título del reporte.
  final String titulo;

  /// Una breve descripción (opcional) del reporte.
  final String? descripcion;

  /// El nombre de la categoría a la que pertenece el reporte.
  final String categoria;

  /// Las coordenadas geográficas [LatLng] (latitud, longitud) del reporte.
  final LatLng location;

  /// Indica si el reporte es prioritario (ej. por tener muchos apoyos).
  final bool esPrioritario;

  /// Crea una instancia de [Reporte].
  Reporte({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.categoria,
    required this.location,
    required this.esPrioritario,
  });

  /// Crea una instancia de [Reporte] a partir de un mapa JSON.
  ///
  /// Este factory es utilizado para deserializar la respuesta de la API.
  /// Maneja el parseo del campo GeoJSON [location] a un objeto [LatLng]
  /// y el campo [es_prioritario].
  factory Reporte.fromJson(Map<String, dynamic> json) {
    // Parsea el formato GeoJSON [lon, lat]
    final coords = json['location']['coordinates'];

    return Reporte(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      categoria: json['categoria'],
      // Nota: GeoJSON es (longitud, latitud), LatLng es (latitud, longitud)
      location: LatLng(coords[1], coords[0]),
      esPrioritario: json['es_prioritario'] ?? false,
    );
  }
}