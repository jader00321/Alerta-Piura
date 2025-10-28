/// Representa una categoría de reporte.
///
/// Este modelo simple se usa para definir los tipos de incidentes
/// que los usuarios pueden reportar (ej. "Robo", "Accidente", "Vandalismo").
class Categoria {
  /// El identificador numérico único para la categoría.
  final int id;

  /// El nombre visible de la categoría (ej. "Robo").
  final String nombre;

  /// Crea una instancia de [Categoria].
  Categoria({required this.id, required this.nombre});

  /// Crea una instancia de [Categoria] a partir de un mapa JSON.
  ///
  /// Este factory es utilizado para deserializar la respuesta de la API.
  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(id: json['id'], nombre: json['nombre']);
  }
}