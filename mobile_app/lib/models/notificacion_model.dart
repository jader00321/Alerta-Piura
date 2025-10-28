/// Representa una notificación individual enviada al usuario.
///
/// Este modelo se utiliza para poblar la lista del historial de
/// notificaciones en el perfil del usuario.
class Notificacion {
  /// El ID único de la notificación.
  final int id;

  /// El título principal de la notificación.
  final String titulo;

  /// El texto o cuerpo del mensaje de la notificación.
  final String cuerpo;

  /// Indica si el usuario ya ha marcado esta notificación como leída.
  final bool leido;

  /// La fecha y hora en que se envió la notificación.
  final DateTime fechaEnvio;

  /// Crea una instancia de [Notificacion].
  Notificacion({
    required this.id,
    required this.titulo,
    required this.cuerpo,
    required this.leido,
    required this.fechaEnvio,
  });

  /// Crea una instancia de [Notificacion] a partir de un mapa JSON.
  ///
  /// Este factory es utilizado para deserializar la respuesta de la API.
  /// Parsea la cadena de fecha [fecha_envio] a un objeto [DateTime].
  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id'],
      titulo: json['titulo'],
      cuerpo: json['cuerpo'],
      leido: json['leido'],
      fechaEnvio: DateTime.parse(json['fecha_envio']),
    );
  }
}