/// Define el tipo de entidad que está siendo reportada para moderación.
enum TipoReporteModeracion {
  /// El reporte es sobre un [Comentario].
  comentario,

  /// El reporte es sobre un [Usuario].
  usuario
}

/// Representa un reporte de moderación hecho por un líder.
///
/// Esto es un "reporte sobre un reporte" o "reporte sobre un usuario",
/// no un reporte de incidente cívico. Se usa para que los líderes
/// marquen contenido inapropiado (comentarios) o usuarios problemáticos.
class ReporteModeracion {
  /// El ID único de *este* reporte de moderación.
  final int id;

  /// La justificación o motivo por el cual se reporta.
  final String motivo;

  /// El estado actual de este reporte de moderación (ej. "pendiente", "resuelto").
  final String estado;

  /// La fecha de creación del reporte (formateada como String).
  final String fecha;

  /// Un objeto [DateTime] usado internamente para ordenar la lista de reportes.
  final DateTime sortDate;

  /// El contenido que está siendo reportado.
  ///
  /// - Si [tipo] es [TipoReporteModeracion.comentario], este es el texto del comentario.
  /// - Si [tipo] es [TipoReporteModeracion.usuario], este es el nombre/alias del usuario.
  final String contenido;

  /// El tipo de entidad que está siendo reportada.
  final TipoReporteModeracion tipo;

  /// El ID del reporte cívico original donde se encuentra el comentario.
  ///
  /// Es `null` si el [tipo] es [TipoReporteModeracion.usuario].
  final int? idReporte;

  /// El ID del usuario que está siendo reportado.
  ///
  /// Es `null` si el [tipo] es [TipoReporteModeracion.comentario].
  final int? idUsuarioReportado;

  /// El código (ej. "R-12345") del reporte cívico original.
  ///
  /// Es `null` si el [tipo] es [TipoReporteModeracion.usuario].
  final String? codigoReporte;

  /// Crea una instancia de [ReporteModeracion].
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
    this.codigoReporte,
  });

  /// Crea una instancia de [ReporteModeracion] a partir de un mapa JSON.
  ///
  /// Este factory es utilizado para deserializar la respuesta de la API.
  /// Requiere que se especifique el [tipo] de antemano, ya que la API
  /// devuelve comentarios y usuarios desde endpoints separados.
  factory ReporteModeracion.fromJson(
      Map<String, dynamic> json, TipoReporteModeracion tipo) {
    return ReporteModeracion(
      id: json['id'],
      motivo: json['motivo'] ?? 'Sin motivo',
      estado: json['estado'] ?? 'desconocido',
      fecha: json['fecha'] ?? 'Fecha desconocida',
      // Usar tryParse para evitar errores si la fecha no es válida
      sortDate: DateTime.tryParse(json['sort_date'] ?? '') ?? DateTime.now(),
      contenido: json['contenido'] ?? '-',
      tipo: tipo,
      idReporte:
          tipo == TipoReporteModeracion.comentario ? json['id_reporte'] : null,
      idUsuarioReportado: tipo == TipoReporteModeracion.usuario
          ? json['id_usuario_reportado']
          : null,
      codigoReporte: tipo == TipoReporteModeracion.comentario
          ? json['codigo_reporte']
          : null,
    );
  }
}