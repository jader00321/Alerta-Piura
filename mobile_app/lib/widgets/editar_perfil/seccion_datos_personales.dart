import 'package:flutter/material.dart';
import 'package:mobile_app/api/perfil_service.dart';

/// {@template seccion_datos_personales}
/// Widget [StatefulWidget] que encapsula el formulario para editar
/// la información personal del usuario: nombre, alias, teléfono y correo electrónico.
///
/// Se utiliza dentro de [EditarPerfilScreen].
/// Este widget maneja sus propios [TextEditingController]s y el estado de carga (`_isSaving`).
///
/// Por seguridad, para guardar los cambios (especialmente el email),
/// muestra un diálogo de confirmación ([_showConfirmationDialog]) que
/// solicita la contraseña actual del usuario antes de enviar los cambios a la API.
/// {@endtemplate}
class SeccionDatosPersonales extends StatefulWidget {
  /// Valor inicial para el campo 'Nombre Completo', recibido del [Perfil] cargado.
  final String nombreInicial;
  /// Valor inicial para el campo 'Alias'.
  final String aliasInicial;
  /// Valor inicial para el campo 'Teléfono'.
  final String telefonoInicial;
  /// Valor inicial para el campo 'Correo Electrónico'.
  final String emailInicial;
  /// Callback que se ejecuta cuando el perfil se ha actualizado exitosamente.
  /// Se usa para notificar a [EditarPerfilScreen] que debe cerrar y refrescar
  /// el [PerfilScreen] anterior.
  final Function onProfileUpdated;

  /// {@macro seccion_datos_personales}
  const SeccionDatosPersonales({
    super.key,
    required this.nombreInicial,
    required this.aliasInicial,
    required this.telefonoInicial,
    required this.emailInicial,
    required this.onProfileUpdated,
  });

  @override
  State<SeccionDatosPersonales> createState() => _SeccionDatosPersonalesState();
}

/// Estado para [SeccionDatosPersonales].
class _SeccionDatosPersonalesState extends State<SeccionDatosPersonales> {
  late TextEditingController _nombreController;
  late TextEditingController _aliasController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;
  final _perfilService = PerfilService();
  
  /// Indica si se está procesando el guardado de datos.
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    /// Inicializa los controladores con los valores iniciales del widget.
    _nombreController = TextEditingController(text: widget.nombreInicial);
    _aliasController = TextEditingController(text: widget.aliasInicial);
    _telefonoController = TextEditingController(text: widget.telefonoInicial);
    _emailController = TextEditingController(text: widget.emailInicial);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _aliasController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Muestra un [AlertDialog] que solicita la contraseña actual del usuario
  /// como medida de seguridad antes de permitir la actualización de datos.
  void _showConfirmationDialog() {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Cambios'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Por seguridad, ingresa tu contraseña actual para guardar los cambios.'),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña Actual',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'La contraseña es requerida' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                /// Si la contraseña es válida, cierra el diálogo y devuelve la contraseña.
                Navigator.pop(ctx, passwordController.text);
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    ).then((password) {
      /// El valor devuelto por showDialog (la contraseña) se recibe aquí.
      if (password != null && password.isNotEmpty) {
        _updateProfileData(password);
      }
    });
  }

  /// Envía los datos actualizados a los endpoints de la API.
  ///
  /// Llama a [PerfilService.updateMyProfile] para datos no sensibles.
  /// Si el email cambió, llama adicionalmente a [PerfilService.updateMyEmail]
  /// pasando la contraseña para verificación del backend.
  ///
  /// Muestra [SnackBar]s con el resultado y llama a [widget.onProfileUpdated]
  /// si todas las operaciones son exitosas.
  Future<void> _updateProfileData(String password) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    bool emailChanged = _emailController.text.trim() != widget.emailInicial;
    bool profileSuccess = true;
    String profileMessage = 'Datos actualizados con éxito.';

    try {
      /// 1. Actualizar datos no sensibles (nombre, alias, teléfono).
      /// Esta llamada no requiere contraseña en la API.
      profileSuccess = await _perfilService.updateMyProfile(
        _nombreController.text.trim(),
        _aliasController.text.trim(),
        _telefonoController.text.trim(),
      );

      /// 2. Si el email cambió, actualizarlo por separado.
      /// Esta llamada SÍ requiere la contraseña para la API.
      if (profileSuccess && emailChanged) {
        final emailResponse = await _perfilService.updateMyEmail(
          _emailController.text.trim(),
          password,
        );
        if (emailResponse['statusCode'] != 200) {
          profileSuccess = false;
          profileMessage =
              emailResponse['data']['message'] ?? 'Error al actualizar email.';
        }
      }

      /// 3. Manejar el resultado final.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(profileMessage),
          backgroundColor: profileSuccess ? Colors.green : Colors.red,
        ));
        if (profileSuccess) {
          widget.onProfileUpdated(); // Notifica al padre (EditarPerfilScreen)
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Datos Personales',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                    labelText: 'Nombre Completo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 16),
            TextFormField(
                controller: _aliasController,
                decoration: const InputDecoration(
                    labelText: 'Alias (Público)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.alternate_email))),
            const SizedBox(height: 16),
            TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_outlined)),
                keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined)),
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 24),
            /// Botón de acción para guardar.
            ElevatedButton(
              onPressed: _isSaving ? null : _showConfirmationDialog,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isSaving
                  ? const CircularProgressIndicator()
                  : const Text('Guardar Datos Personales'),
            ),
          ],
        ),
      ),
    );
  }
}