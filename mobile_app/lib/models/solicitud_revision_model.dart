class SolicitudRevision {
  final int id;
  final int idReporte;
  final String estado;
  final String fecha;
  final String titulo;

  SolicitudRevision({
    required this.id,
    required this.idReporte,
    required this.estado,
    required this.fecha,
    required this.titulo,
  });

  factory SolicitudRevision.fromJson(Map<String, dynamic> json) {
    return SolicitudRevision(
      id: json['id'],
      idReporte: json['id_reporte'],
      estado: json['estado'],
      fecha: json['fecha'],
      titulo: json['titulo'],
    );
  }
}
