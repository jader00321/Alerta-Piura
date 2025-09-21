class SolicitudRevision {
  final int id;
  final int id_reporte; // <-- ADD THIS
  final String estado;
  final String fecha;
  final String titulo;

  SolicitudRevision({
    required this.id,
    required this.id_reporte, // <-- ADD THIS
    required this.estado,
    required this.fecha,
    required this.titulo,
  });

  factory SolicitudRevision.fromJson(Map<String, dynamic> json) {
    return SolicitudRevision(
      id: json['id'],
      id_reporte: json['id_reporte'], // <-- ADD THIS
      estado: json['estado'],
      fecha: json['fecha'],
      titulo: json['titulo'],
    );
  }
}