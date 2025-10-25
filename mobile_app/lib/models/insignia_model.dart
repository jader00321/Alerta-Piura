// lib/models/insignia_model.dart

class Insignia {
  final String nombre;
  final String descripcion;
  final String? iconoUrl;
  final int? puntosNecesarios;

  Insignia({
    required this.nombre, 
    required this.descripcion,
    this.iconoUrl,
    this.puntosNecesarios,
  });

  factory Insignia.fromJson(Map<String, dynamic> json) {
    return Insignia(
      nombre: json['nombre'],
      descripcion: json['descripcion'] ?? 'Sin descripción',
      iconoUrl: json['icono_url'],
      puntosNecesarios: (json['puntos_necesarios'] as num?)?.toInt(),
    );
  }
}