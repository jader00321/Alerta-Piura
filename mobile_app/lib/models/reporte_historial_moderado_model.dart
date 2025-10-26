// lib/models/reporte_historial_moderado_model.dart (NUEVO ARCHIVO)

class ReporteHistorialModerado {
  final int id;
  final String titulo;
  final String estado; // verificado, rechazado, fusionado
  final String categoria;
  final String fecha; // Formatted
  final int? idReporteOriginal; // Para fusionados

  ReporteHistorialModerado({
    required this.id,
    required this.titulo,
    required this.estado,
    required this.categoria,
    required this.fecha,
    this.idReporteOriginal,
  });

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
