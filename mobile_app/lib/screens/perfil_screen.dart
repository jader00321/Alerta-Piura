import 'package:flutter/material.dart';
import 'package:mobile_app/api/perfil_service.dart';
import 'package:mobile_app/models/perfil_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final PerfilService _perfilService = PerfilService();
  late Future<Perfil> _perfilFuture;

  @override
  void initState() {
    super.initState();
    // We still fetch profile data for points and badges, which are not in the token
    _perfilFuture = _perfilService.getMiPerfil();
  }

  // A new method to refresh the data
  void _refreshProfile() {
    setState(() {
      _perfilFuture = _perfilService.getMiPerfil();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the authNotifier to display basic user info instantly
    final authNotifier = Provider.of<AuthNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            tooltip: 'Editar Perfil',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/editar-perfil');
              if (result == true) {
                // When we come back, refresh both the provider and the local profile data
                await authNotifier.checkAuthStatus();
                _refreshProfile();
              }
            },
          )
        ],
      ),
      body: FutureBuilder<Perfil>(
        future: _perfilFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar el perfil: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No se encontraron datos del perfil.'));
          }

          final perfil = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              _refreshProfile();
            },
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
                        const SizedBox(height: 16),
                        Text(
                          perfil.alias ?? perfil.nombre,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(perfil.email),
                        const SizedBox(height: 24),
                        Text(
                          '${perfil.puntos}',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.teal, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Puntos',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.list_alt),
                  title: const Text('Mi Actividad'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // This navigation is now simple and doesn't need to await a result
                    // because the state is managed globally.
                    Navigator.pushNamed(context, '/mi_actividad');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Configuración'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                const Divider(),
                Text('Insignias Obtenidas', style: Theme.of(context).textTheme.titleLarge),
                const Divider(),
                if (perfil.insignias.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Aún no has ganado ninguna insignia. ¡Sigue participando!'),
                  )
                else
                  ...perfil.insignias.map((insignia) => ListTile(
                        leading: const Icon(Icons.shield, color: Colors.amber),
                        title: Text(insignia.nombre),
                        subtitle: Text(insignia.descripcion),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }
}