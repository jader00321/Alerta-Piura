class HistorialPago {
  final String id; // UUID
  final String montoPagado;
  final String estadoTransaccion;
  final String fechaFormateada;
  final String nombrePlan;

  HistorialPago({
    required this.id,
    required this.montoPagado,
    required this.estadoTransaccion,
    required this.fechaFormateada,
    required this.nombrePlan,
  });

  factory HistorialPago.fromJson(Map<String, dynamic> json) {
    return HistorialPago(
      id: json['id'],
      montoPagado: json['monto_pagado'],
      estadoTransaccion: json['estado_transaccion'],
      fechaFormateada: json['fecha_formateada'],
      nombrePlan: json['nombre_plan'],
    );
  }
}