class PlanSuscripcion {
  final int id;
  final String identificadorPlan;
  final String nombrePublico;
  final String? descripcion;
  final String precioMensual;

  PlanSuscripcion({
    required this.id,
    required this.identificadorPlan,
    required this.nombrePublico,
    this.descripcion,
    required this.precioMensual,
  });

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