class ReportePendiende {
  final int id;
  final String titulo;
  final String? descripcion;
  final String fecha;
  final String estado;
  final String categoria;

  ReportePendiende({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.fecha,
    required this.estado,
    required this.categoria, 
  });

  factory ReportePendiende.fromJson(Map<String, dynamic> json) {
    return ReportePendiende(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      fecha: json['fecha'],
      estado: json['estado'],
      categoria: json['categoria'],
    );
  }
}