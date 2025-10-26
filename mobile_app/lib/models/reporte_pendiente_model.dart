// lib/models/reporte_pendiente_model.dart

// Asegúrate de que el nombre de la clase sea consistente (ReportePendiente)
class ReportePendiente {
  final int id;
  final String titulo;
  final String estado; // Debe ser 'pendiente_verificacion'
  final String fecha; // Formatted date string from backend
  final String? fotoUrl;
  final String categoria;
  final String autor; // Alias/Nombre or 'Anónimo'
  final bool esPrioritario;
  final String? urgencia;
  final int apoyosPendientes;

  ReportePendiente({
    required this.id,
    required this.titulo,
    required this.estado,
    required this.fecha,
    this.fotoUrl,
    required this.categoria,
    required this.autor,
    required this.esPrioritario,
    this.urgencia,
    required this.apoyosPendientes,
  });

  factory ReportePendiente.fromJson(Map<String, dynamic> json) {
    return ReportePendiente(
      id: json['id'],
      titulo: json['titulo'] ?? 'Sin Título', // Fallback
      estado: json['estado'],
      fecha: json['fecha'] ?? 'Fecha desconocida', // Fallback
      fotoUrl: json['foto_url'],
      categoria: json['categoria'] ?? 'Sin Categoría', // Fallback
      autor: json['autor'] ?? 'Desconocido', // Fallback
      esPrioritario: json['es_prioritario'] ?? false,
      urgencia: json['urgencia'],
      apoyosPendientes: (json['apoyos_pendientes'] as num?)?.toInt() ?? 0,
    );
  }
}
