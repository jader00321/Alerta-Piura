/// Representa un comentario hecho por un usuario en un reporte.
class Comentario {
  /// El ID único del comentario.
  final int id;

  /// El ID del usuario que escribió el comentario.
  ///
  /// Útil para verificar si el usuario actual es el autor.
  final int idUsuario;

  /// El contenido de texto del comentario.
  final String comentario;

  /// El nombre o alias del autor del comentario.
  final String autor;

  /// La fecha de creación del comentario (formateada como String, ej. "hace 2 horas").
  final String fechaCreacion;

  /// El número de apoyos (likes) que ha recibido el comentario.
  final int apoyosCount;

  /// Crea una instancia de [Comentario].
  Comentario({
    required this.id,
    required this.idUsuario,
    required this.comentario,
    required this.autor,
    required this.fechaCreacion,
    required this.apoyosCount,
  });

  /// Crea una instancia de [Comentario] a partir de un mapa JSON.
  ///
  /// Este factory es utilizado para deserializar la respuesta de la API.
  /// Maneja la conversión de `apoyos_count` (que viene como String) a [int].
  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      id: json['id'],
      idUsuario: json['id_usuario'],
      comentario: json['comentario'],
      autor: json['autor'],
      fechaCreacion: json['fecha_creacion'],
      // Parsea el conteo de apoyos que la API envía como String.
      apoyosCount: int.parse(json['apoyos_count']),
    );
  }
}