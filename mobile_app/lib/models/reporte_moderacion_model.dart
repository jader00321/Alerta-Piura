enum TipoReporteModeracion { comentario, usuario }

class ReporteModeracion {
  final int id;
  final String motivo;
  final String estado;
  final String fecha;
  final DateTime sortDate; // <-- ADD THIS PROPERTY
  final String contenido;
  final TipoReporteModeracion tipo;

  ReporteModeracion({
    required this.id,
    required this.motivo,
    required this.estado,
    required this.fecha,
    required this.sortDate, // <-- ADD TO CONSTRUCTOR
    required this.contenido,
    required this.tipo,
  });

  factory ReporteModeracion.fromJson(Map<String, dynamic> json, TipoReporteModeracion tipo) {
    return ReporteModeracion(
      id: json['id'],
      motivo: json['motivo'],
      estado: json['estado'],
      fecha: json['fecha'],
      sortDate: DateTime.parse(json['sort_date']), // <-- PARSE THE RAW DATE
      contenido: json['contenido'],
      tipo: tipo,
    );
  }
}