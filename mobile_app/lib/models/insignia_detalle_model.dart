/// Representa el detalle de una insignia específica del sistema de gamificación.
///
/// Incluye información sobre la insignia y si el usuario actual
/// ya la ha ganado (`isEarned`).
class InsigniaDetalle {
  /// El ID único de la insignia.
  final int id;

  /// El nombre oficial de la insignia (ej. "Colaborador Nivel 1").
  final String nombre;

  /// La descripción de cómo obtener la insignia.
  final String descripcion;

  /// La URL (opcional) del ícono o imagen de la insignia.
  final String? iconoUrl;

  /// El número de puntos (opcional) necesarios para desbloquear esta insignia.
  final int? puntosNecesarios;

  /// Indica si el usuario actual ya ha ganado esta insignia.
  final bool isEarned;

  /// Crea una instancia de [InsigniaDetalle].
  InsigniaDetalle({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.iconoUrl,
    this.puntosNecesarios,
    required this.isEarned,
  });

  /// Crea una instancia de [InsigniaDetalle] a partir de un mapa JSON.
  ///
  /// Este factory es utilizado para deserializar la respuesta de la API.
  /// Maneja valores nulos para `descripcion`, `icono_url`,
  /// `puntos_necesarios` y `isEarned`.
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

/// Clase contenedora para la respuesta completa de la API de progreso de insignias.
///
/// Agrupa los puntos totales del usuario y la lista completa de [insignias]
/// (tanto ganadas como por ganar).
class ProgresoInsignias {
  /// Los puntos de gamificación totales acumulados por el usuario.
  final int puntosUsuario;

  /// La lista completa de todas las insignias disponibles en el sistema.
  final List<InsigniaDetalle> insignias;

  /// Crea una instancia de [ProgresoInsignias].
  ProgresoInsignias({required this.puntosUsuario, required this.insignias});

  /// Crea una instancia de [ProgresoInsignias] a partir de un mapa JSON.
  ///
  /// Este factory es utilizado para deserializar la respuesta de la API.
  /// Parsea `puntosUsuario` y la lista anidada de `insignias`.
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