/// Representa un reporte cercano a la ubicación del usuario.
///
/// Este modelo se utiliza para mostrar reportes en un mapa o lista
/// de "cercanos", e incluye información clave como la distancia,
/// el estado y si el usuario actual ya se ha unido (apoyado)
/// al reporte pendiente.
class ReporteCercano {
  /// El ID único del reporte.
  final int id;

  /// El título del reporte.
  final String titulo;

  /// El nombre de la categoría a la que pertenece el reporte.
  final String categoria;

  /// El estado actual del reporte (ej. "pendiente", "verificado").
  final String estado;

  /// La URL (opcional) de la foto principal del reporte.
  final String? fotoUrl;

  /// El contador total de apoyos que ha recibido este reporte
  /// mientras estaba en estado "pendiente".
  final int apoyosPendientes;

  /// La distancia en metros desde la ubicación del usuario hasta el reporte.
  final double distanciaMetros;

  /// El ID del usuario que creó el reporte.
  final int idUsuario;

  /// El nombre o alias del autor del reporte.
  final String autor;

  /// La fecha de creación (formateada como String, ej. "hace 5 min").
  final String fechaCreacionFormateada;

  /// Indica si el reporte fue marcado como prioritario (basado en apoyos pendientes).
  final bool esPrioritario;

  /// El nivel de urgencia reportado (ej. "alta", "media").
  final String? urgencia;

  /// Indica si el usuario *puede* unirse a este reporte (ej. si está pendiente).
  final bool puedeUnirse;

  /// Indica si el usuario actual ya se unió (apoyó) a este reporte pendiente.
  final bool usuarioActualUnido;

  /// Crea una instancia de [ReporteCercano].
  ReporteCercano({
    required this.id,
    required this.titulo,
    required this.categoria,
    required this.estado,
    this.fotoUrl,
    required this.apoyosPendientes,
    required this.distanciaMetros,
    required this.idUsuario,
    required this.autor,
    required this.fechaCreacionFormateada,
    required this.esPrioritario,
    this.urgencia,
    required this.puedeUnirse,
    required this.usuarioActualUnido,
  });

  /// Crea una instancia de [ReporteCercano] a partir de un mapa JSON.
  ///
  /// Este factory es utilizado para deserializar la respuesta de la API.
  /// Maneja la conversión de tipos numéricos y valores nulos.
  factory ReporteCercano.fromJson(Map<String, dynamic> json) {
    return ReporteCercano(
      id: json['id'],
      titulo: json['titulo'],
      categoria: json['categoria'],
      estado: json['estado'],
      fotoUrl: json['foto_url'],
      apoyosPendientes: (json['apoyos_pendientes'] as num?)?.toInt() ?? 0,
      distanciaMetros: (json['distancia_metros'] as num).toDouble(),
      idUsuario: json['id_usuario'],
      autor: json['autor'],
      fechaCreacionFormateada: json['fecha_creacion_formateada'],
      esPrioritario: json['es_prioritario'] ?? false,
      urgencia: json['urgencia'],
      puedeUnirse: json['puede_unirse'] ?? false,
      usuarioActualUnido: json['usuario_actual_unido'] ?? false,
    );
  }
}