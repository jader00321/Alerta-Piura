/// Representa un reporte en el historial de moderación de un líder.
///
/// Este es un modelo resumido que se usa para listar los reportes
/// que ya han sido procesados (verificados, rechazados o fusionados).
class ReporteHistorialModerado {
  /// El ID único del reporte.
  final int id;

  /// El título del reporte.
  final String titulo;

  /// El estado final de la moderación (ej. "verificado", "rechazado", "fusionado").
  final String estado;

  /// El nombre de la categoría a la que pertenece el reporte.
  final String categoria;

  /// La fecha en que se realizó la moderación (formateada como String).
  final String fecha;

  /// Si el [estado] es "fusionado", este es el ID del reporte original
  /// al cual este reporte fue vinculado.
  final int? idReporteOriginal;

  /// Crea una instancia de [ReporteHistorialModerado].
  ReporteHistorialModerado({
    required this.id,
    required this.titulo,
    required this.estado,
    required this.categoria,
    required this.fecha,
    this.idReporteOriginal,
  });

  /// Crea una instancia de [ReporteHistorialModerado] a partir de un mapa JSON.
  ///
  /// Este factory es utilizado para deserializar la respuesta de la API.
  /// Proporciona valores por defecto para campos que podrían ser nulos.
  factory ReporteHistorialModerado.fromJson(Map<String, dynamic> json) {
    return ReporteHistorialModerado(
      id: json['id'],
      titulo: json['titulo'] ?? 'Sin título',
      estado: json['estado'] ?? 'desconocido',
      categoria: json['categoria'] ?? 'Sin categoría',
      fecha: json['fecha'] ?? 'Fecha desconocida',
      idReporteOriginal: json['id_reporte_original'],
    );
  }
}