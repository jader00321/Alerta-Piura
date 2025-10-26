import 'package:flutter/material.dart';
import 'package:mobile_app/api/perfil_service.dart';
import 'package:mobile_app/models/perfil_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

// Importamos los nuevos widgets que hemos creado
import 'package:mobile_app/widgets/editar_perfil/seccion_datos_personales.dart';
import 'package:mobile_app/widgets/editar_perfil/seccion_seguridad.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_lista_actividad.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final PerfilService _perfilService = PerfilService();
  late Future<Perfil> _perfilFuture;

  @override
  void initState() {
    super.initState();
    _perfilFuture = _perfilService.getMiPerfil();
  }

  // Esta función se pasará como callback para refrescar el estado del AuthProvider
  // y notificar a la pantalla anterior que debe recargar los datos.
  void _onProfileUpdated() {
    if (mounted) {
      Provider.of<AuthNotifier>(context, listen: false).checkAuthStatus();
      // Se podría pasar un valor al hacer pop, pero el refresh en la pantalla de perfil ya maneja la recarga.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: FutureBuilder<Perfil>(
        future: _perfilFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Usamos un esqueleto de carga para una mejor UX
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: EsqueletoListaActividad(),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
                child: Text('Error al cargar la información del perfil.'));
          }

          final perfil = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Renderizamos el primer widget con los datos personales iniciales
                SeccionDatosPersonales(
                  nombreInicial: perfil.nombre,
                  aliasInicial: perfil.alias ?? '',
                  telefonoInicial: perfil.telefono ?? '',
                  emailInicial: perfil.email,
                  onProfileUpdated: _onProfileUpdated,
                ),
                const SizedBox(height: 24),
                // Renderizamos el segundo widget para la seguridad
                const SeccionSeguridad(),
              ],
            ),
          );
        },
      ),
    );
  }
}
