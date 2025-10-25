// lib/models/zona_segura_model.dart
import 'package:latlong2/latlong.dart';

class ZonaSegura {
  final int id;
  final String nombre;
  final int radioMetros;
  final LatLng centro;

  ZonaSegura({
    required this.id,
    required this.nombre,
    required this.radioMetros,
    required this.centro,
  });

  factory ZonaSegura.fromJson(Map<String, dynamic> json) {
    return ZonaSegura(
      id: json['id'],
      nombre: json['nombre'],
      radioMetros: json['radio_metros'],
      centro: LatLng(json['lat'], json['lon']),
    );
  }
}