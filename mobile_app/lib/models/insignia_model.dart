class Insignia {
  final String nombre;
  final String descripcion;

  Insignia({required this.nombre, required this.descripcion});

  factory Insignia.fromJson(Map<String, dynamic> json) {
    return Insignia(
      nombre: json['nombre'],
      descripcion: json['descripcion'] ?? 'Sin descripción',
    );
  }
}