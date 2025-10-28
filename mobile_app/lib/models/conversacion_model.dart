/// Representa un resumen de una conversación (chat) asociada a un reporte.
///
/// Este modelo se usa en la lista de chats del líder, mostrando
/// el reporte al que pertenece la conversación.
class Conversacion {
  /// El ID del reporte al que está vinculada esta conversación.
  final int idReporte;

  /// El título del reporte, usado para identificar la conversación.
  final String tituloReporte;

  /// Crea una instancia de [Conversacion].
  Conversacion({required this.idReporte, required this.tituloReporte});

  /// Crea una instancia de [Conversacion] a partir de un mapa JSON.
  ///
  /// Este factory es utilizado para deserializar la respuesta de la API.
  /// Mapea 'id' (del reporte) a [idReporte] y 'titulo' a [tituloReporte].
  factory Conversacion.fromJson(Map<String, dynamic> json) {
    return Conversacion(
      idReporte: json['id'],
      tituloReporte: json['titulo'],
    );
  }
}