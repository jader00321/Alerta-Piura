import 'package:flutter/material.dart';
import 'package:mobile_app/api/perfil_service.dart';

class SeccionDatosPersonales extends StatefulWidget {
  final String nombreInicial;
  final String aliasInicial;
  final String telefonoInicial;
  final String emailInicial;
  final Function onProfileUpdated;

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

class _SeccionDatosPersonalesState extends State<SeccionDatosPersonales> {
  late TextEditingController _nombreController;
  late TextEditingController _aliasController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;
  final _perfilService = PerfilService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _updateProfileData(String password) async {
    setState(() => _isSaving = true);
    bool profileUpdated = false;
    String finalMessage = 'Datos actualizados con éxito.';

    try {
      // Actualizar datos básicos
      profileUpdated = await _perfilService.updateMyProfile(
        _nombreController.text,
        _aliasController.text,
        _telefonoController.text,
      );

      // Si el email ha cambiado, actualizarlo también
      if (_emailController.text != widget.emailInicial) {
        final emailResponse = await _perfilService.updateMyEmail(_emailController.text, password);
        if (emailResponse['statusCode'] != 200) {
          finalMessage = emailResponse['data']['message'];
          profileUpdated = false; // Marcar como fallido si el email falla
        }
      }

      if (profileUpdated) {
        widget.onProfileUpdated();
      }
    } catch (e) {
      finalMessage = 'Ocurrió un error de conexión.';
      profileUpdated = false;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(finalMessage),
        backgroundColor: profileUpdated ? Colors.green : Colors.red,
      ));
      if (profileUpdated) {
        Navigator.of(context).pop(true);
      }
    }

    setState(() => _isSaving = false);
  }

  void _showConfirmationDialog() {
    final passwordConfirmController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Cambios'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Para guardar los cambios, por favor ingresa tu contraseña actual.'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordConfirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña Actual', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final password = passwordConfirmController.text;
              Navigator.pop(ctx);
              if (password.isNotEmpty) {
                _updateProfileData(password);
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Datos Personales', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre Completo', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 16),
            TextFormField(controller: _aliasController, decoration: const InputDecoration(labelText: 'Alias (Público)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.alternate_email))),
            const SizedBox(height: 16),
            TextFormField(controller: _telefonoController, decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone_outlined)), keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Correo Electrónico', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email_outlined)), keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _showConfirmationDialog,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isSaving ? const CircularProgressIndicator() : const Text('Guardar Datos Personales'),
            ),
          ],
        ),
      ),
    );
  }
}