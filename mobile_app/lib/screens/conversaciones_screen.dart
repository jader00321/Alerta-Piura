import 'package:flutter/material.dart';
import 'package:mobile_app/api/perfil_service.dart';
import 'package:mobile_app/models/conversacion_model.dart';
import 'package:mobile_app/screens/chat_screen.dart';

class ConversacionesScreen extends StatefulWidget {
  const ConversacionesScreen({super.key});
  @override
  State<ConversacionesScreen> createState() => _ConversacionesScreenState();
}
class _ConversacionesScreenState extends State<ConversacionesScreen> {
  late Future<List<Conversacion>> _conversacionesFuture;
  @override
  void initState() {
    super.initState();
    _conversacionesFuture = PerfilService().getMisConversaciones();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mensajes de Moderadores')),
      body: FutureBuilder<List<Conversacion>>(
        future: _conversacionesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tienes conversaciones activas.'));
          }
          final conversaciones = snapshot.data!;
          return ListView.builder(
            itemCount: conversaciones.length,
            itemBuilder: (context, index) {
              final conv = conversaciones[index];
              return ListTile(
                leading: const Icon(Icons.chat),
                title: Text('Reporte: ${conv.tituloReporte}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      reporteId: conv.idReporte,
                      reporteTitulo: conv.tituloReporte,
                    ),
                  ));
                },
              );
            },
          );
        },
      ),
    );
  }
}