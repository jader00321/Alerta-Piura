import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/api/perfil_service.dart';
import 'package:mobile_app/models/notificacion_model.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});
  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  late Future<List<Notificacion>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = PerfilService().getMisNotificaciones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: FutureBuilder<List<Notificacion>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tienes notificaciones.'));
          }
          final notifications = snapshot.data!;
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return ListTile(
                leading: Icon(notif.leido ? Icons.drafts : Icons.mark_email_unread, color: notif.leido ? Colors.grey : Theme.of(context).primaryColor),
                title: Text(notif.titulo, style: TextStyle(fontWeight: notif.leido ? FontWeight.normal : FontWeight.bold)),
                subtitle: Text(notif.cuerpo),
                trailing: Text(DateFormat('dd MMM').format(notif.fechaEnvio)),
              );
            },
          );
        },
      ),
    );
  }
}