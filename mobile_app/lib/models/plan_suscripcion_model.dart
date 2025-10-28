/// Representa un plan de suscripción disponible para la compra.
///
/// Este modelo define los detalles de un plan, como su precio
/// y nombre, que se muestran al usuario en la pantalla de pagos.
class PlanSuscripcion {
  /// El ID numérico único del plan en la base de datos.
  final int id;

  /// El identificador interno del plan (ej. "plan_premium_mensual").
  ///
  /// Usado para la lógica interna o la comunicación con la pasarela de pago.
  final String identificadorPlan;

  /// El nombre del plan que se muestra al usuario (ej. "Plan Premium").
  final String nombrePublico;

  /// Una descripción opcional de los beneficios del plan.
  final String? descripcion;

  /// El precio mensual del plan (formateado como String, ej. "S/ 9.99").
  final String precioMensual;

  /// Crea una instancia de [PlanSuscripcion].
  PlanSuscripcion({
    required this.id,
    required this.identificadorPlan,
    required this.nombrePublico,
    this.descripcion,
    required this.precioMensual,
  });

  /// Crea una instancia de [PlanSuscripcion] a partir de un mapa JSON.
  ///
  /// Este factory es utilizado para deserializar la respuesta de la API.
  factory PlanSuscripcion.fromJson(Map<String, dynamic> json) {
    return PlanSuscripcion(
      id: json['id'],
      identificadorPlan: json['identificador_plan'],
      nombrePublico: json['nombre_publico'],
      descripcion: json['descripcion'],
      precioMensual: json['precio_mensual'],
    );
  }
}