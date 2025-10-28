import 'package:flutter/material.dart';
import 'package:mobile_app/api/perfil_service.dart';
import 'package:mobile_app/models/conversacion_model.dart';
import 'package:mobile_app/screens/chat_screen.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_lista_reportes.dart';

/// {@template conversaciones_screen}
/// Pantalla que muestra una lista de las conversaciones de chat activas
/// del usuario (generalmente un líder vecinal).
///
/// Cada conversación está vinculada a un reporte específico.
/// {@endtemplate}
class ConversacionesScreen extends StatefulWidget {
  /// {@macro conversaciones_screen}
  const ConversacionesScreen({super.key});
  @override
  State<ConversacionesScreen> createState() => _ConversacionesScreenState();
}

/// Estado para [ConversacionesScreen].
///
/// Maneja la carga y actualización de la lista de [Conversacion].
class _ConversacionesScreenState extends State<ConversacionesScreen> {
  /// Futuro que contiene la lista de conversaciones.
  late Future<List<Conversacion>> _conversacionesFuture;

  @override
  void initState() {
    super.initState();
    _conversacionesFuture = PerfilService().getMisConversaciones();
  }

  /// Recarga la lista de conversaciones desde la API.
  Future<void> _refreshConversaciones() async {
    setState(() {
      _conversacionesFuture = PerfilService().getMisConversaciones();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Conversaciones'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshConversaciones,
        child: FutureBuilder<List<Conversacion>>(
          future: _conversacionesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const EsqueletoListaReportes();
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text(
                      'Error al cargar las conversaciones: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'No tienes conversaciones activas con usuarios.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              );
            }

            final conversaciones = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: conversaciones.length,
              itemBuilder: (context, index) {
                final conv = conversaciones[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: const Text(
                      'Conversación sobre el reporte:',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    subtitle: Text(
                      conv.tituloReporte,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            reporteId: conv.idReporte,
                            reporteTitulo: conv.tituloReporte,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}