/*import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/api/perfil_service.dart';
import 'package:mobile_app/models/notificacion_model.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_lista_notificaciones.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});
  
  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  late Future<List<Notificacion>> _notificationsFuture;
  final PerfilService _perfilService = PerfilService();

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _perfilService.getMisNotificaciones();
  }
  
  Future<void> _refreshNotifications() async {
    setState(() {
      _notificationsFuture = _perfilService.getMisNotificaciones();
    });
  }

  Future<void> _markAllAsRead() async {
    final success = await _perfilService.marcarTodasComoLeidas();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todas las notificaciones marcadas como leídas.')),
      );
      _refreshNotifications();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al realizar la acción.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          Tooltip(
            message: 'Marcar todo como leído',
            child: IconButton(
              icon: const Icon(Icons.mark_chat_read_outlined),
              onPressed: _markAllAsRead,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: FutureBuilder<List<Notificacion>>(
          future: _notificationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const EsqueletoListaNotificaciones();
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error al cargar notificaciones: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'No tienes notificaciones.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final notifications = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                  color: notif.leido ? null : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: notif.leido ? Colors.grey.shade300 : Theme.of(context).colorScheme.primary,
                      child: Icon(
                        notif.leido ? Icons.mark_email_read_outlined : Icons.notifications_active,
                        color: notif.leido ? Colors.grey.shade700 : Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    title: Text(
                      notif.titulo,
                      style: TextStyle(fontWeight: notif.leido ? FontWeight.normal : FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(notif.cuerpo),
                    ),
                    trailing: Text(
                      DateFormat('dd MMM, HH:mm').format(notif.fechaEnvio),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}*/