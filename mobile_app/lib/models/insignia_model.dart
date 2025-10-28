/// Representa una insignia que un usuario puede ganar.
///
/// Este modelo se usa para mostrar la información básica de una insignia,
/// como en el perfil del usuario.
class Insignia {
  /// El nombre oficial de la insignia (ej. "Primer Reporte").
  final String nombre;

  /// La descripción de cómo se obtiene la insignia.
  final String descripcion;

  /// La URL (opcional) del ícono o imagen de la insignia.
  final String? iconoUrl;

  /// El número de puntos (opcional) necesarios para desbloquear esta insignia.
  final int? puntosNecesarios;

  /// Crea una instancia de [Insignia].
  Insignia({
    required this.nombre,
    required this.descripcion,
    this.iconoUrl,
    this.puntosNecesarios,
  });

  /// Crea una instancia de [Insignia] a partir de un mapa JSON.
  ///
  /// Este factory es utilizado para deserializar la respuesta de la API.
  /// Maneja valores nulos para `descripcion`, `icono_url` y `puntos_necesarios`.
  factory Insignia.fromJson(Map<String, dynamic> json) {
    return Insignia(
      nombre: json['nombre'],
      descripcion: json['descripcion'] ?? 'Sin descripción',
      iconoUrl: json['icono_url'],
      puntosNecesarios: (json['puntos_necesarios'] as num?)?.toInt(),
    );
  }
}