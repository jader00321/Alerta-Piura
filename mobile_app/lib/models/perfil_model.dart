import 'package:mobile_app/models/insignia_model.dart';

/// Representa el perfil completo del usuario autenticado.
///
/// Este modelo contiene toda la información personal del usuario,
/// sus datos de gamificación (puntos e insignias) y el estado
/// de su suscripción.
class Perfil {
  /// El nombre real completo del usuario.
  final String nombre;

  /// El apodo o alias opcional del usuario.
  final String? alias;

  /// El correo electrónico de inicio de sesión del usuario.
  final String email;

  /// El total de puntos de gamificación acumulados por el usuario.
  final int puntos;

  /// El número de teléfono opcional del usuario.
  final String? telefono;

  /// La lista de insignias que el usuario ha ganado.
  final List<Insignia> insignias;

  /// El nombre del plan de suscripción activo (ej. "Premium").
  ///
  /// Es `null` si el usuario no tiene una suscripción activa.
  final String? nombrePlan;

  /// La fecha y hora en que expira la suscripción activa.
  ///
  /// Es `null` si el usuario no tiene una suscripción activa.
  final DateTime? fechaFinSuscripcion;

  /// Crea una instancia de [Perfil].
  Perfil({
    required this.nombre,
    this.alias,
    required this.email,
    required this.puntos,
    this.telefono,
    required this.insignias,
    this.nombrePlan,
    this.fechaFinSuscripcion,
  });

  /// Crea una instancia de [Perfil] a partir de un mapa JSON.
  ///
  /// Este factory es utilizado para deserializar la respuesta de la API.
  /// Maneja la deserialización de la lista anidada de [insignias]
  /// y parsea la [fecha_fin_suscripcion] (si existe) a un objeto [DateTime].
  factory Perfil.fromJson(Map<String, dynamic> json) {
    var list = json['insignias'] as List;
    List<Insignia> insigniasList =
        list.map((i) => Insignia.fromJson(i)).toList();

    return Perfil(
      nombre: json['nombre'],
      alias: json['alias'],
      email: json['email'],
      puntos: json['puntos'],
      telefono: json['telefono'],
      insignias: insigniasList,
      nombrePlan: json['nombre_plan'],
      fechaFinSuscripcion: json['fecha_fin_suscripcion'] != null
          ? DateTime.parse(json['fecha_fin_suscripcion'])
          : null,
    );
  }
}