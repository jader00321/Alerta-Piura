class Conversacion {
  final int idReporte;
  final String tituloReporte;

  Conversacion({required this.idReporte, required this.tituloReporte});

  factory Conversacion.fromJson(Map<String, dynamic> json) {
    return Conversacion(
      idReporte: json['id'],
      tituloReporte: json['titulo'],
    );
  }
}