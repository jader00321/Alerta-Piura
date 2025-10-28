/// Representa los detalles completos de una boleta de pago (factura).
///
/// Este modelo se utiliza para mostrar la información detallada de una
/// transacción de suscripción específica en el historial de pagos del usuario.
class BoletaDetalle {
  /// El ID único de la boleta en la base de datos local.
  final String id;

  /// El monto total pagado en la transacción (ej. "S/ 10.00").
  final String montoPagado;

  /// El estado final de la transacción (ej. "Pagado", "Fallido").
  final String estadoTransaccion;

  /// El ID de la transacción devuelto por la pasarela de pagos (ej. Stripe, Izipay).
  final String idTransaccionPasarela;

  /// La fecha y hora completa de la transacción (formateada como String).
  final String fechaCompleta;

  /// El nombre del plan de suscripción adquirido (ej. "Plan Premium Mensual").
  final String nombrePlan;

  /// El tipo o marca de la tarjeta usada (ej. "Visa", "Mastercard").
  final String tipoTarjeta;

  /// Los últimos cuatro dígitos de la tarjeta usada para el pago.
  final String ultimosCuatroDigitos;

  /// El nombre completo del usuario que realizó el pago.
  final String nombreUsuario;

  /// El correo electrónico del usuario que realizó el pago.
  final String emailUsuario;

  /// Crea una instancia de [BoletaDetalle].
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

  /// Crea una instancia de [BoletaDetalle] a partir de un mapa JSON.
  ///
  /// Este factory es utilizado para deserializar la respuesta de la API.
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