/// Representa una solicitud de revisión creada por un líder.
///
/// Este modelo se usa en la lista "Mis Solicitudes" del líder,
/// mostrando las solicitudes que ha enviado y su estado actual.
class SolicitudRevision {
  /// El ID único de la solicitud de revisión en sí.
  final int id;

  /// El ID del reporte cívico al que hace referencia esta solicitud.
  final int idReporte;

  /// El estado actual de la solicitud (ej. "pendiente", "resuelta").
  final String estado;

  /// La fecha de creación de la solicitud (formateada como String).
  final String fecha;

  /// El título del reporte asociado, para fácil identificación.
  final String titulo;

  /// Crea una instancia de [SolicitudRevision].
  SolicitudRevision({
    required this.id,
    required this.idReporte,
    required this.estado,
    required this.fecha,
    required this.titulo,
  });

  /// Crea una instancia de [SolicitudRevision] a partir de un mapa JSON.
  ///
  /// Este factory es utilizado para deserializar la respuesta de la API.
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