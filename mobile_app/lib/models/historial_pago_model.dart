/// Representa un ítem en el historial de pagos del usuario.
///
/// Este es un modelo resumido que se usa para poblar la lista
/// del historial de transacciones.
class HistorialPago {
  /// El ID único de la transacción (UUID).
  final String id;

  /// El monto total pagado (formateado como String, ej. "S/ 10.00").
  final String montoPagado;

  /// El estado de la transacción (ej. "Pagado", "Fallido").
  final String estadoTransaccion;

  /// La fecha de la transacción (formateada como String, ej. "25 oct 2025").
  final String fechaFormateada;

  /// El nombre del plan que se adquirió en esta transacción.
  final String nombrePlan;

  /// Crea una instancia de [HistorialPago].
  HistorialPago({
    required this.id,
    required this.montoPagado,
    required this.estadoTransaccion,
    required this.fechaFormateada,
    required this.nombrePlan,
  });

  /// Crea una instancia de [HistorialPago] a partir de un mapa JSON.
  ///
  /// Este factory es utilizado para deserializar la respuesta de la API.
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