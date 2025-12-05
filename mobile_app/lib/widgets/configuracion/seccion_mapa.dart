import 'package:flutter/material.dart';

/// {@template seccion_mapa}
/// Widget reutilizable que muestra la sección de "Mapa y Navegación"
/// dentro de la pantalla de [SettingsScreen].
///
/// Sirve como punto de entrada para la gestión avanzada de ubicaciones,
/// permitiendo al usuario navegar a [PantallaGestionarUbicaciones].
/// {@endtemplate}
class SeccionMapa extends StatelessWidget {
  /// {@macro seccion_mapa}
  const SeccionMapa({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.map_outlined),
        title: const Text('Preferencias de Mapa'),
        subtitle: const Text('Gestionar ubicaciones guardadas y punto de inicio.'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navega a la nueva pantalla de gestión
          Navigator.pushNamed(context, '/gestionar_ubicaciones');
        },
      ),
    );
  }
}