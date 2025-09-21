class Comentario {
  final int id;
  final int idUsuario; // <-- AÑADIDO
  final String comentario;
  final String autor;
  final String fechaCreacion;
  final int apoyosCount;

  Comentario({
    required this.id,
    required this.idUsuario, // <-- AÑADIDO
    required this.comentario,
    required this.autor,
    required this.fechaCreacion,
    required this.apoyosCount,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      id: json['id'],
      idUsuario: json['id_usuario'], // <-- AÑADIDO
      comentario: json['comentario'],
      autor: json['autor'],
      fechaCreacion: json['fecha_creacion'],
      apoyosCount: int.parse(json['apoyos_count']),
    );
  }
}