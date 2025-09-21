import 'package:latlong2/latlong.dart';

class Reporte {
  final int id;
  final String titulo;
  final String? descripcion;
  final String categoria;
  final LatLng location;

  Reporte({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.categoria,
    required this.location,
  });

  factory Reporte.fromJson(Map<String, dynamic> json) {
    final coords = json['location']['coordinates'];
    return Reporte(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      categoria: json['categoria'],
      location: LatLng(coords[1], coords[0]),
    );
  }
}