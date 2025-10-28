import 'package:flutter/material.dart';
import 'package:mobile_app/api/perfil_service.dart';
import 'package:mobile_app/models/perfil_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/widgets/editar_perfil/seccion_datos_personales.dart';
import 'package:mobile_app/widgets/editar_perfil/seccion_seguridad.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_lista_actividad.dart';

/// {@template editar_perfil_screen}
/// Pantalla que permite al usuario editar su información personal y de seguridad.
///
/// Esta pantalla está dividida en dos secciones principales:
/// - [SeccionDatosPersonales]: Para nombre, alias, teléfono y email.
/// - [SeccionSeguridad]: Para cambiar la contraseña.
///
/// Carga el perfil actual del usuario para pre-llenar los campos.
/// {@endtemplate}
class EditarPerfilScreen extends StatefulWidget {
  /// {@macro editar_perfil_screen}
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

/// Estado para [EditarPerfilScreen].
class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final PerfilService _perfilService = PerfilService();
  
  /// Futuro que contiene la información del perfil del usuario.
  late Future<Perfil> _perfilFuture;

  @override
  void initState() {
    super.initState();
    _perfilFuture = _perfilService.getMiPerfil();
  }

  /// Callback que se ejecuta cuando los datos del perfil se actualizan
  /// exitosamente en un widget hijo (ej. [SeccionDatosPersonales]).
  ///
  /// Refresca el estado del [AuthNotifier] y notifica a la pantalla anterior
  /// (PerfilScreen) que debe recargar los datos.
  void _onProfileUpdated() {
    if (mounted) {
      Provider.of<AuthNotifier>(context, listen: false).refreshUserStatus();
      Navigator.pop(context, true); // Devuelve 'true' para indicar éxito
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
                SeccionDatosPersonales(
                  nombreInicial: perfil.nombre,
                  aliasInicial: perfil.alias ?? '',
                  telefonoInicial: perfil.telefono ?? '',
                  emailInicial: perfil.email,
                  onProfileUpdated: _onProfileUpdated,
                ),
                const SizedBox(height: 24),
                const SeccionSeguridad(),
              ],
            ),
          );
        },
      ),
    );
  }
}