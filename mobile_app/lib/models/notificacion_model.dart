class Notificacion {
  final int id;
  final String titulo;
  final String cuerpo;
  final bool leido;
  final DateTime fechaEnvio;

  Notificacion({
    required this.id,
    required this.titulo,
    required this.cuerpo,
    required this.leido,
    required this.fechaEnvio,
  });

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