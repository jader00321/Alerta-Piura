import 'dart:convert';
import 'package:flutter/foundation.dart';
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
  final int? idReporteOriginal;
  final int reportesVinculadosCount;

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
    this.idReporteOriginal,
    required this.reportesVinculadosCount,
  });

  static int _parseInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) {
      return defaultValue;
    }
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  factory ReporteDetallado.fromJson(Map<String, dynamic> json) {
    var list = (json['comentarios'] as List? ?? [])
        .map((i) => Comentario.fromJson(i))
        .toList();

    LatLng parsedLocation;
    try {
      dynamic locationData = json['location'];
      if (locationData is String) {
        locationData = jsonDecode(locationData);
      }
      final coords = locationData?['coordinates'];
      if (coords != null && coords is List && coords.length >= 2) {
        parsedLocation = LatLng(coords[1], coords[0]);
      } else {
        throw Exception('Invalid coordinates format');
      }
    } catch (e) {
      debugPrint("Error parseando location, usando default: $e");
      parsedLocation = const LatLng(0, 0);
    }

    List<String> tagsList = [];
    if (json['tags'] != null && json['tags'] is List) {
      try {
        tagsList = List<String>.from(json['tags'].map((tag) => tag.toString()));
      } catch (e) {
        debugPrint("Error parseando tags: $e");
      }
    }

    return ReporteDetallado(
      id: _parseInt(json['id']),
      titulo: json['titulo'] ?? 'Sin Título',
      descripcion: json['descripcion'],
      fotoUrl: json['foto_url'],
      fechaCreacion: json['fecha_creacion'] ?? 'Fecha desconocida',
      autor: json['autor'] ?? 'Anónimo',
      idAutor: _parseInt(json['id_autor']),
      apoyosCount: _parseInt(json['apoyos_count']),
      estado: json['estado'] ?? 'desconocido',
      esAnonimo: json['es_anonimo'] ?? false,
      categoria: json['categoria'] ?? 'Sin Categoría',
      location: parsedLocation,
      comentarios: list,
      urgencia: json['urgencia'],
      distrito: json['distrito'],
      referenciaUbicacion: json['referencia_ubicacion'],
      horaIncidente: json['hora_incidente'],
      tags: tagsList,
      impacto: json['impacto'],
      codigoReporte: json['codigo_reporte'],
      idReporteOriginal: _parseInt(json['id_reporte_original'], -1) == -1
          ? null
          : _parseInt(json['id_reporte_original']),
      reportesVinculadosCount: _parseInt(json['reportes_vinculados_count']),
    );
  }
}
