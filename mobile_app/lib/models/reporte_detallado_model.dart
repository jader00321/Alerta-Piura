import 'dart:convert'; // <-- ADD THIS IMPORT
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/models/comentario_model.dart';

class ReporteDetallado {
  final int id;
  final String titulo;
  final String? descripcion;
  final String? fotoUrl;
  final String fechaCreacion;
  final String autor;
  final int apoyosCount;
  final String estado;
  final String categoria;
  final LatLng location;
  final List<Comentario> comentarios;

  ReporteDetallado({
    required this.id,
    required this.titulo,
    this.descripcion,
    this.fotoUrl,
    required this.fechaCreacion,
    required this.autor,
    required this.apoyosCount,
    required this.estado,
    required this.categoria,
    required this.location,
    required this.comentarios,
  });

  factory ReporteDetallado.fromJson(Map<String, dynamic> json) {
    var list = json['comentarios'] as List;
    List<Comentario> comentariosList =
        list.map((i) => Comentario.fromJson(i)).toList();

    // --- THIS IS THE KEY FIX ---
    // 1. Decode the location string into a Map
    final locationMap = jsonDecode(json['location']);
    // 2. Access the coordinates from the map
    final coords = locationMap['coordinates'];
    // 3. Create the LatLng object
    final parsedLocation = LatLng(coords[1], coords[0]);

    return ReporteDetallado(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      fotoUrl: json['foto_url'],
      fechaCreacion: json['fecha_creacion'],
      autor: json['autor'],
      apoyosCount: int.parse(json['apoyos_count']),
      estado: json['estado'],
      categoria: json['categoria'],
      location: parsedLocation,
      comentarios: comentariosList,
    );
  }
}