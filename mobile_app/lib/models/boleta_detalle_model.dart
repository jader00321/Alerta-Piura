class BoletaDetalle {
  final String id;
  final String montoPagado;
  final String estadoTransaccion;
  final String idTransaccionPasarela;
  final String fechaCompleta;
  final String nombrePlan;
  final String tipoTarjeta;
  final String ultimosCuatroDigitos;
  final String nombreUsuario;
  final String emailUsuario;

  BoletaDetalle({
    required this.id,
    required this.montoPagado,
    required this.estadoTransaccion,
    required this.idTransaccionPasarela,
    required this.fechaCompleta,
    required this.nombrePlan,
    required this.tipoTarjeta,
    required this.ultimosCuatroDigitos,
    required this.nombreUsuario,
    required this.emailUsuario,
  });

  factory BoletaDetalle.fromJson(Map<String, dynamic> json) {
    return BoletaDetalle(
      id: json['id'],
      montoPagado: json['monto_pagado'],
      estadoTransaccion: json['estado_transaccion'],
      idTransaccionPasarela: json['id_transaccion_pasarela'],
      fechaCompleta: json['fecha_completa'],
      nombrePlan: json['nombre_plan'],
      tipoTarjeta: json['tipo_tarjeta'],
      ultimosCuatroDigitos: json['ultimos_cuatro_digitos'],
      nombreUsuario: json['nombre_usuario'],
      emailUsuario: json['email_usuario'],
    );
  }
}
