import 'package:flutter/material.dart';

/// {@template seccion_notificaciones}
/// Un widget reutilizable que muestra la sección de "Notificaciones"
/// dentro de la pantalla de [SettingsScreen].
///
/// Actualmente, este widget sirve como un punto de navegación. Muestra un
/// [ListTile] que, al ser presionado, redirige al usuario a la pantalla
/// de historial de notificaciones (`/alertas` o [PantallaAlertas]).
///
/// *Nota: Este widget podría expandirse en el futuro para incluir
/// `SwitchListTile`s que permitan activar/desactivar tipos específicos
/// de notificaciones (ej. "Comentarios", "Estado de Reporte").*
/// {@endtemplate}
class SeccionNotificaciones extends StatelessWidget {
  /// {@macro seccion_notificaciones}
  const SeccionNotificaciones({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.notifications_outlined),
        title: const Text('Historial de Notificaciones'),
        subtitle: const Text('Ver mensajes y alertas del sistema.'),
        trailing: const Icon(Icons.chevron_right),
        /// Navega a la pantalla de historial de alertas al ser presionado.
        onTap: () {
          Navigator.pushNamed(context, '/alertas');
        },
      ),
    );
  }
}