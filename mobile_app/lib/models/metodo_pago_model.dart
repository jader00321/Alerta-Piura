class MetodoPago {
  final int id;
  final String tipoTarjeta;
  final String ultimosCuatroDigitos;
  final String fechaExpiracion;
  final bool esPredeterminado;

  MetodoPago({
    required this.id,
    required this.tipoTarjeta,
    required this.ultimosCuatroDigitos,
    required this.fechaExpiracion,
    required this.esPredeterminado,
  });

  factory MetodoPago.fromJson(Map<String, dynamic> json) {
    return MetodoPago(
      id: json['id'],
      tipoTarjeta: json['tipo_tarjeta'] ?? 'VISA',
      ultimosCuatroDigitos: json['ultimos_cuatro_digitos'],
      fechaExpiracion: json['fecha_expiracion'],
      esPredeterminado: json['es_predeterminado'] ?? false,
    );
  }
}