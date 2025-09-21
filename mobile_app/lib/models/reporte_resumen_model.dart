class ReporteResumen {
  final int id;
  final String titulo;
  final String estado;
  final String? fecha; // <-- The type is now a nullable String

  ReporteResumen({
    required this.id,
    required this.titulo,
    required this.estado,
    this.fecha, // <-- The field is now optional
  });

  factory ReporteResumen.fromJson(Map<String, dynamic> json) {
    return ReporteResumen(
      id: json['id'],
      titulo: json['titulo'],
      estado: json['estado'],
      fecha: json['fecha'], // This will now correctly handle a null value
    );
  }
}