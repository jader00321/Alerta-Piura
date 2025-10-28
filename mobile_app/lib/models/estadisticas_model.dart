/// Representa un resumen de las estadísticas de actividad de un usuario.
///
/// Contiene los conteos totales de reportes, apoyos y comentarios
/// generados por el usuario.
class EstadisticasResumen {
  /// El número total de reportes creados por el usuario.
  final int totalReportes;

  /// El número total de apoyos dados por el usuario.
  final int totalApoyos;

  /// El número total de comentarios hechos por el usuario.
  final int totalComentarios;

  /// Crea una instancia de [EstadisticasResumen].
  EstadisticasResumen({
    required this.totalReportes,
    required this.totalApoyos,
    required this.totalComentarios,
  });

  /// Crea una instancia de [EstadisticasResumen] a partir de un mapa JSON.
  ///
  /// Este factory es utilizado para deserializar la respuesta de la API.
  /// Incluye un `toString()` para convertir de forma segura los valores
  /// (que pueden venir como `String` o `int`) antes de parsear a [int].
  factory EstadisticasResumen.fromJson(Map<String, dynamic> json) {
    return EstadisticasResumen(
      totalReportes: int.parse(json['total_reportes'].toString()),
      totalApoyos: int.parse(json['total_apoyos'].toString()),
      totalComentarios: int.parse(json['total_comentarios'].toString()),
    );
  }
}

/// Representa un punto de dato genérico para ser usado en gráficos.
///
/// Comúnmente usado para gráficos de pastel o barras, donde [name]
/// es la etiqueta (ej. "Robo") y [value] es la cantidad.
class DatoGrafico {
  /// La etiqueta o nombre de la serie (ej. "Categoría A", "Distrito X").
  final String name;

  /// El valor numérico asociado a la etiqueta (ej. 15, 25.5).
  final double value;

  /// Crea una instancia de [DatoGrafico].
  DatoGrafico({required this.name, required this.value});

  /// Crea una instancia de [DatoGrafico] a partir de un mapa JSON.
  ///
  /// Este factory es utilizado para deserializar la respuesta de la API.
  /// Incluye un `toString()` para convertir de forma segura el valor
  /// (que puede venir como `String`, `int` o `double`) antes de parsear a [double].
  factory DatoGrafico.fromJson(Map<String, dynamic> json) {
    return DatoGrafico(
      name: json['name'],
      value: double.parse(json['value'].toString()),
    );
  }
}