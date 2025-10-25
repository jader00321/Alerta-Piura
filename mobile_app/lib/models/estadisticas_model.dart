// lib/models/estadisticas_model.dart

class EstadisticasResumen {
  final int totalReportes;
  final int totalApoyos;
  final int totalComentarios;

  EstadisticasResumen({
    required this.totalReportes,
    required this.totalApoyos,
    required this.totalComentarios,
  });

  factory EstadisticasResumen.fromJson(Map<String, dynamic> json) {
    return EstadisticasResumen(
      totalReportes: int.parse(json['total_reportes'].toString()),
      totalApoyos: int.parse(json['total_apoyos'].toString()),
      totalComentarios: int.parse(json['total_comentarios'].toString()),
    );
  }
}

class DatoGrafico {
  final String name;
  final double value;

  DatoGrafico({required this.name, required this.value});

  factory DatoGrafico.fromJson(Map<String, dynamic> json) {
    return DatoGrafico(
      name: json['name'],
      value: double.parse(json['value'].toString()),
    );
  }
}

