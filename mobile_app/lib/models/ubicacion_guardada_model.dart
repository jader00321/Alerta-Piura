//import 'dart:convert';
import 'package:latlong2/latlong.dart';

/// Representa una ubicación geográfica guardada por el usuario como favorita.
class UbicacionGuardada {
  /// ID único para identificar la ubicación (usamos el timestamp de creación).
  final String id;

  /// Nombre personalizado (ej. "Casa", "Trabajo", "Plaza de Armas").
  final String nombre;

  /// Latitud de la ubicación.
  final double lat;

  /// Longitud de la ubicación.
  final double lng;

  /// Fecha de creación para ordenar la lista.
  final DateTime fechaCreacion;

  UbicacionGuardada({
    required this.id,
    required this.nombre,
    required this.lat,
    required this.lng,
    required this.fechaCreacion,
  });

  /// Convierte el modelo a un mapa JSON para guardarlo en SharedPreferences.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'lat': lat,
      'lng': lng,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  /// Crea una instancia desde un mapa JSON recuperado de SharedPreferences.
  factory UbicacionGuardada.fromJson(Map<String, dynamic> json) {
    return UbicacionGuardada(
      id: json['id'],
      nombre: json['nombre'],
      lat: json['lat'],
      lng: json['lng'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
    );
  }

  /// Helper para obtener el objeto LatLng directamente.
  LatLng toLatLng() => LatLng(lat, lng);
}