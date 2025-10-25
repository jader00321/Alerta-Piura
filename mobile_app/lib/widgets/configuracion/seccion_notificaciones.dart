import 'package:flutter/material.dart';

class SeccionNotificaciones extends StatelessWidget {
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
        onTap: () {
          Navigator.pushNamed(context, '/alertas'); // Navega a la pantalla de alertas
        },
      ),
    );
  }
}