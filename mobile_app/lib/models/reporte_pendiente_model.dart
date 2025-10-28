/// Representa un reporte que está pendiente de moderación por un líder.
///
/// Este es un modelo resumido que se usa para poblar la lista
/// de reportes en la cola de moderación.
class ReportePendiente {
  /// El ID único del reporte.
  final int id;

  /// El título del reporte.
  final String titulo;

  /// El estado del reporte (debería ser 'pendiente_verificacion').
  final String estado;

  /// La fecha de creación del reporte (formateada como String, ej. "hace 1 día").
  final String fecha;

  /// La URL (opcional) de la foto principal del reporte.
  final String? fotoUrl;

  /// El nombre de la categoría a la que pertenece el reporte.
  final String categoria;

  /// El nombre o alias del autor del reporte (o 'Anónimo').
  final String autor;

  /// Indica si el reporte es prioritario (basado en apoyos, urgencia, etc.).
  final bool esPrioritario;

  /// El nivel de urgencia reportado (ej. "alta", "media").
  final String? urgencia;

  /// El número de apoyos ("unirse") que recibió el reporte mientras estaba pendiente.
  final int apoyosPendientes;

  /// Crea una instancia de [ReportePendiente].
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

  /// Crea una instancia de [ReportePendiente] a partir de un mapa JSON.
  ///
  /// Este factory es utilizado para deserializar la respuesta de la API.
  /// Proporciona valores por defecto (fallbacks) para campos que
  /// podrían ser nulos y parsea de forma segura [apoyos_pendientes].
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