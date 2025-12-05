/// Modelo para el indicador de eficiencia (Tiempo promedio).
class TiemposAtencion {
  final String tiempoPromedioHoras;
  final int totalProcesados;

  TiemposAtencion({
    required this.tiempoPromedioHoras,
    required this.totalProcesados,
  });

  factory TiemposAtencion.fromJson(Map<String, dynamic> json) {
    return TiemposAtencion(
      // Manejo seguro de tipos (el backend puede mandar string o número)
      tiempoPromedioHoras: json['tiempoPromedioHoras']?.toString() ?? '0.0',
      totalProcesados: int.tryParse(json['totalProcesados']?.toString() ?? '0') ?? 0,
    );
  }
}

/// Modelo simple para un punto en el mapa de calor.
class PuntoMapaCalor {
  final double lat;
  final double lon;

  PuntoMapaCalor({required this.lat, required this.lon});

  factory PuntoMapaCalor.fromJson(Map<String, dynamic> json) {
    return PuntoMapaCalor(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }
}