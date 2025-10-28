import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/models/comentario_model.dart';

/// Representa la vista completa y detallada de un reporte.
///
/// Este modelo se usa en la pantalla de detalles del reporte e incluye
/// toda la información del reporte, así como la lista anidada de [comentarios].
class ReporteDetallado {
  /// El ID único del reporte.
  final int id;

  /// El título del reporte.
  final String titulo;

  /// La descripción detallada (opcional) del reporte.
  final String? descripcion;

  /// La URL (opcional) de la foto principal adjunta al reporte.
  final String? fotoUrl;

  /// La fecha de creación (formateada como String, ej. "hace 2 horas").
  final String fechaCreacion;

  /// El nombre o alias del autor del reporte.
  final String autor;

  /// El ID del usuario que creó el reporte.
  final int idAutor;

  /// El número de apoyos (likes) que ha recibido el reporte.
  final int apoyosCount;

  /// El estado actual del reporte (ej. "pendiente", "verificado", "rechazado").
  final String estado;

  /// `true` si el reporte fue publicado de forma anónima.
  final bool esAnonimo;

  /// El nombre de la categoría a la que pertenece el reporte.
  final String categoria;

  /// Las coordenadas geográficas [LatLng] (latitud, longitud) del reporte.
  final LatLng location;

  /// La lista de [Comentario]s asociados a este reporte.
  final List<Comentario> comentarios;

  /// El nivel de urgencia reportado (ej. "alta", "media").
  final String? urgencia;

  /// El distrito donde ocurrió el incidente.
  final String? distrito;

  /// Una referencia textual adicional para la ubicación (ej. "frente al parque").
  final String? referenciaUbicacion;

  /// La hora aproximada del incidente (formateada como String, ej. "14:30").
  final String? horaIncidente;

  /// Una lista de etiquetas (tags) asociadas al reporte.
  final List<String> tags;

  /// El nivel de impacto reportado (ej. "alto", "medio").
  final String? impacto;

  /// Un código alfanumérico único para el reporte (ej. "R-12345").
  final String? codigoReporte;

  /// Si este reporte fue fusionado, este es el ID del reporte original.
  ///
  /// Es `null` si este reporte no es un duplicado fusionado.
  final int? idReporteOriginal;

  /// El número de otros reportes que han sido fusionados *en* este.
  ///
  /// (Es decir, cuántos duplicados se han vinculado a este reporte).
  final int reportesVinculadosCount;

  /// Crea una instancia de [ReporteDetallado].
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

  /// Función de ayuda estática para parsear un valor a [int] de forma segura.
  ///
  /// Maneja `null`, `int`, `double` y `String`.
  static int _parseInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Crea una instancia de [ReporteDetallado] a partir de un mapa JSON.
  ///
  /// Este factory es utilizado para deserializar la respuesta de la API.
  /// Es robusto y maneja:
  /// - Parseo de la lista anidada de [comentarios].
  /// - Parseo seguro de [location] (GeoJSON).
  /// - Parseo seguro de la lista de [tags].
  /// - Parseo seguro de campos numéricos usando [_parseInt].
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
      // Added null checks for safety
      final coords = locationData?['coordinates'];
      if (coords != null && coords is List && coords.length >= 2) {
        parsedLocation = LatLng(coords[1], coords[0]);
      } else {
        throw Exception('Invalid coordinates format');
      }
    } catch (e) {
      print("Error parseando location, usando default: $e");
      parsedLocation = const LatLng(0, 0); // Fallback seguro
    }

    List<String> tagsList = [];
    if (json['tags'] != null && json['tags'] is List) {
      try {
        // Ensure all elements are strings before converting
        tagsList = List<String>.from(json['tags'].map((tag) => tag.toString()));
      } catch (e) {
        print("Error parseando tags: $e");
      }
    }

    return ReporteDetallado(
      id: _parseInt(json['id']), // Usar helper
      titulo: json['titulo'] ?? 'Sin Título',
      descripcion: json['descripcion'],
      fotoUrl: json['foto_url'],
      fechaCreacion: json['fecha_creacion'] ?? 'Fecha desconocida',
      autor: json['autor'] ?? 'Anónimo',
      idAutor: _parseInt(json['id_autor']), // Usar helper
      apoyosCount: _parseInt(json['apoyos_count']), // Usar helper
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
          : _parseInt(json['id_reporte_original']), // Maneja null/int/string
      reportesVinculadosCount: _parseInt(json['reportes_vinculados_count']),
    );
  }
}