import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/models/comentario_model.dart';

class ReporteDetallado {
  final int id;
  final String titulo;
  final String? descripcion;
  final String? fotoUrl;
  final String fechaCreacion;
  final String autor;
  final int idAutor;
  final int apoyosCount;
  final String estado;
  final bool esAnonimo;
  final String categoria;
  final LatLng location;
  final List<Comentario> comentarios;
  final String? urgencia;
  final String? distrito;
  final String? referenciaUbicacion;
  final String? horaIncidente;
  final List<String> tags;
  final String? impacto;
  final String? codigoReporte;

  ReporteDetallado({
    required this.id,
    required this.titulo,
    this.descripcion,
    this.fotoUrl,
    required this.fechaCreacion,
    required this.autor,
    required this.idAutor,
    required this.apoyosCount,
    required this.estado,
    required this.esAnonimo,
    required this.categoria,
    required this.location,
    required this.comentarios,
    this.urgencia,
    this.distrito,
    this.referenciaUbicacion,
    this.horaIncidente,
    required this.tags,
    this.impacto,
    this.codigoReporte,
  });

  factory ReporteDetallado.fromJson(Map<String, dynamic> json) {
    var list = json['comentarios'] as List;
    List<Comentario> comentariosList = list.map((i) => Comentario.fromJson(i)).toList();

    // This robust parsing logic handles the GeoJSON string from the backend
    final locationMap = jsonDecode(json['location']);
    final coords = locationMap['coordinates'];
    final parsedLocation = LatLng(coords[1], coords[0]);

    List<String> tagsList = [];
    if (json['tags'] != null && (json['tags'] as List).isNotEmpty) {
      tagsList = List<String>.from(json['tags']);
    }

    return ReporteDetallado(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      fotoUrl: json['foto_url'],
      fechaCreacion: json['fecha_creacion'],
      autor: json['autor'],
      idAutor: json['id_autor'],
      apoyosCount: int.parse(json['apoyos_count']), // Safely parse from string
      estado: json['estado'],
      esAnonimo: json['es_anonimo'] ?? false,
      categoria: json['categoria'],
      location: parsedLocation,
      comentarios: comentariosList,
      // --- NEW FIELDS ---
      urgencia: json['urgencia'],
      distrito: json['distrito'],
      referenciaUbicacion: json['referencia_ubicacion'],
      horaIncidente: json['hora_incidente'],
      tags: tagsList,
      impacto: json['impacto'],
      codigoReporte: json['codigo_reporte'],
    );
  }
}