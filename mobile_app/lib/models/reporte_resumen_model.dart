/// Representa un resumen de un reporte para ser usado en listas de perfil.
///
/// Este modelo es versátil y se utiliza para poblar las listas de
/// "Mis Reportes", "Mis Apoyos", "Mis Comentarios" y "Seguidos",
/// mostrando la información clave de cada reporte.
class ReporteResumen {
  /// El ID único del reporte.
  final int id;

  /// El título del reporte.
  final String titulo;

  /// El estado actual del reporte (ej. "pendiente", "verificado").
  final String estado;

  /// La fecha de creación (formateada como String, ej. "hace 1 día").
  final String? fecha;

  /// La URL (opcional) de la foto principal del reporte.
  final String? fotoUrl;

  /// El nombre de la categoría a la que pertenece el reporte.
  final String? categoria;

  /// El nombre o alias del autor del reporte.
  final String? autor;

  /// Indica si el reporte es prioritario.
  final bool esPrioritario;

  /// Si este resumen es para la lista "Mis Comentarios", este campo
  /// contiene el texto del último comentario del usuario.
  final String? miComentario;

  /// El nivel de urgencia reportado (ej. "alta", "media").
  final String? urgencia;

  /// El distrito donde ocurrió el incidente.
  final String? distrito;

  /// Crea una instancia de [ReporteResumen].
  ReporteResumen({
    required this.id,
    required this.titulo,
    required this.estado,
    this.fecha,
    this.fotoUrl,
    this.categoria,
    this.autor,
    required this.esPrioritario,
    this.miComentario,
    this.urgencia,
    this.distrito,
  });

  /// Crea una instancia de [ReporteResumen] a partir de un mapa JSON.
  ///
  /// Este factory es utilizado para deserializar la respuesta de la API.
  /// Proporciona valores por defecto (fallbacks) para [titulo] y [estado]
  /// y maneja campos opcionales.
  factory ReporteResumen.fromJson(Map<String, dynamic> json) {
    return ReporteResumen(
      id: json['id'],
      titulo: json['titulo'] ?? 'Sin Título', // Fallback
      estado: json['estado'] ?? 'desconocido', // Fallback
      fecha: json['fecha'],
      fotoUrl: json['foto_url'],
      categoria: json['categoria'],
      autor: json['autor'],
      esPrioritario: json['es_prioritario'] ?? false,
      miComentario: json['mi_comentario'],
      urgencia: json['urgencia'],
      distrito: json['distrito'],
    );
  }
}