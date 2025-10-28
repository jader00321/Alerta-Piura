/// Representa un método de pago (tarjeta) guardado por el usuario.
///
/// Este modelo se utiliza para listar las tarjetas que el usuario ha
/// registrado en su perfil para realizar pagos de suscripción.
class MetodoPago {
  /// El ID único del método de pago en la base de datos.
  final int id;

  /// La marca o tipo de la tarjeta (ej. "Visa", "Mastercard").
  final String tipoTarjeta;

  /// Los últimos cuatro dígitos del número de la tarjeta.
  final String ultimosCuatroDigitos;

  /// La fecha de expiración de la tarjeta (formateada como "MM/YY").
  final String fechaExpiracion;

  /// Indica si esta tarjeta es la seleccionada por defecto para los cobros.
  final bool esPredeterminado;

  /// Crea una instancia de [MetodoPago].
  MetodoPago({
    required this.id,
    required this.tipoTarjeta,
    required this.ultimosCuatroDigitos,
    required this.fechaExpiracion,
    required this.esPredeterminado,
  });

  /// Crea una instancia de [MetodoPago] a partir de un mapa JSON.
  ///
  /// Este factory es utilizado para deserializar la respuesta de la API.
  /// Proporciona valores por defecto para [tipoTarjeta] ('VISA') y
  /// [esPredeterminado] (false) en caso de que la API los omita.
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