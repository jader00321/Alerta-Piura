import 'package:mobile_app/models/insignia_model.dart';

class Perfil {
  final String nombre;
  final String? alias;
  final String email;
  final int puntos;
  final String? telefono;
  final List<Insignia> insignias;

  Perfil({
    required this.nombre,
    this.alias,
    required this.email,
    required this.puntos,
    this.telefono,
    required this.insignias,
  });

  factory Perfil.fromJson(Map<String, dynamic> json) {
    var list = json['insignias'] as List;
    List<Insignia> insigniasList = list.map((i) => Insignia.fromJson(i)).toList();

    return Perfil(
      nombre: json['nombre'],
      alias: json['alias'],
      email: json['email'],
      puntos: json['puntos'],
      telefono: json['telefono'],
      insignias: insigniasList,
    );
  }
}