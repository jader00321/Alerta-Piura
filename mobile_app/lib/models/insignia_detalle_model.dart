// lib/models/insignia_detalle_model.dart

class InsigniaDetalle {
  final int id;
  final String nombre;
  final String descripcion;
  final String? iconoUrl;
  final int? puntosNecesarios;
  final bool isEarned; // <-- ¡Importante!

  InsigniaDetalle({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.iconoUrl,
    this.puntosNecesarios,
    required this.isEarned,
  });

  factory InsigniaDetalle.fromJson(Map<String, dynamic> json) {
    return InsigniaDetalle(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'] ?? 'Sin descripción',
      iconoUrl: json['icono_url'],
      puntosNecesarios: (json['puntos_necesarios'] as num?)?.toInt(),
      isEarned: json['isEarned'] ?? false,
    );
  }
}

// Clase helper para agrupar la respuesta completa de la API
class ProgresoInsignias {
  final int puntosUsuario;
  final List<InsigniaDetalle> insignias;

  ProgresoInsignias({required this.puntosUsuario, required this.insignias});

  factory ProgresoInsignias.fromJson(Map<String, dynamic> json) {
    var list = (json['insignias'] as List? ?? [])
        .map((i) => InsigniaDetalle.fromJson(i))
        .toList();

    return ProgresoInsignias(
      puntosUsuario: (json['puntosUsuario'] as num?)?.toInt() ?? 0,
      insignias: list,
    );
  }
}
