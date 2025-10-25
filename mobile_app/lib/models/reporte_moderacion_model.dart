// lib/models/reporte_moderacion_model.dart

enum TipoReporteModeracion { comentario, usuario }

class ReporteModeracion {
  final int id; // ID del reporte de moderación
  final String motivo;
  final String estado;
  final String fecha;
  final DateTime sortDate; // Usado para ordenar cronológicamente
  final String contenido; // Texto del comentario o alias/nombre del usuario
  final TipoReporteModeracion tipo;
  final int? idReporte; // ID del reporte original (si tipo == comentario)
  final int? idUsuarioReportado; // ID del usuario (si tipo == usuario)
  // --- NUEVO CAMPO ---
  final String? codigoReporte; // Código del reporte original (si tipo == comentario)

  ReporteModeracion({
    required this.id,
    required this.motivo,
    required this.estado,
    required this.fecha,
    required this.sortDate,
    required this.contenido,
    required this.tipo,
    this.idReporte,
    this.idUsuarioReportado,
    this.codigoReporte, // <-- Añadido al constructor
  });

  factory ReporteModeracion.fromJson(Map<String, dynamic> json, TipoReporteModeracion tipo) {
    return ReporteModeracion(
      id: json['id'],
      motivo: json['motivo'] ?? 'Sin motivo',
      estado: json['estado'] ?? 'desconocido',
      fecha: json['fecha'] ?? 'Fecha desconocida',
      // Usar tryParse para evitar errores si la fecha no es válida
      sortDate: DateTime.tryParse(json['sort_date'] ?? '') ?? DateTime.now(),
      contenido: json['contenido'] ?? '-',
      tipo: tipo,
      idReporte: tipo == TipoReporteModeracion.comentario ? json['id_reporte'] : null,
      idUsuarioReportado: tipo == TipoReporteModeracion.usuario ? json['id_usuario_reportado'] : null,
      // --- PARSEAR NUEVO CAMPO ---
      codigoReporte: tipo == TipoReporteModeracion.comentario ? json['codigo_reporte'] : null, // <-- Añadido
    );
  }
}