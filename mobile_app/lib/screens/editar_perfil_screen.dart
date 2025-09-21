import 'package:flutter/material.dart';
import 'package:mobile_app/api/perfil_service.dart';
//import 'package:mobile_app/models/perfil_model.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  // Controllers for personal data
  final _nombreController = TextEditingController();
  final _aliasController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  // Controllers for password change
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureText = true;
  final PerfilService _perfilService = PerfilService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _aliasController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final perfil = await _perfilService.getMiPerfil();
      if (mounted) {
        setState(() {
          _nombreController.text = perfil.nombre;
          _aliasController.text = perfil.alias ?? '';
          _telefonoController.text = perfil.telefono ?? '';
          _emailController.text = perfil.email;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle error
    }
  }
  
  void _showConfirmationDialog({required Function onConfirm}) {
    final passwordConfirmController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Cambios'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Para guardar los cambios, por favor ingresa tu contraseña actual.'),
            TextField(
              controller: passwordConfirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña Actual'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm(passwordConfirmController.text);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _updateProfileData() {
    _showConfirmationDialog(
      onConfirm: (String password) async {
        final success = await _perfilService.updateMyProfile(
          _nombreController.text,
          _aliasController.text,
          _telefonoController.text,
        );
        // We'll also update the email separately if it has changed
        if (_emailController.text != (await _perfilService.getMiPerfil()).email) {
          final emailResponse = await _perfilService.updateMyEmail(_emailController.text, password);
           if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(emailResponse['data']['message'])));
           }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Datos actualizados.')));
          Navigator.pop(context, true); // Pop with true to signal a refresh
        }
      }
    );
  }

  void _updatePassword() {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Las nuevas contraseñas no coinciden.')));
      return;
    }
    // You can add more password strength validation here
    
    _perfilService.updateMyPassword(_currentPasswordController.text, _newPasswordController.text).then((response) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['data']['message']),
          backgroundColor: response['statusCode'] == 200 ? Colors.green : Colors.red,
        ));
        if (response['statusCode'] == 200) {
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Datos Personales', style: Theme.of(context).textTheme.titleLarge),
                    const Divider(),
                    TextFormField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre Completo')),
                    const SizedBox(height: 16),
                    TextFormField(controller: _aliasController, decoration: const InputDecoration(labelText: 'Alias (Opcional)')),
                    const SizedBox(height: 16),
                    TextFormField(controller: _telefonoController, decoration: const InputDecoration(labelText: 'Teléfono (Opcional)')),
                    const SizedBox(height: 16),
                    TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Correo Electrónico')),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _updateProfileData,
                        child: const Text('Guardar Datos Personales'),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text('Seguridad', style: Theme.of(context).textTheme.titleLarge),
                    const Divider(),
                    TextFormField(
                      controller: _currentPasswordController,
                      obscureText: _obscureText,
                      decoration: const InputDecoration(labelText: 'Contraseña Actual'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: 'Nueva Contraseña',
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscureText = !_obscureText),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureText,
                      decoration: const InputDecoration(labelText: 'Confirmar Nueva Contraseña'),
                    ),
                     const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _updatePassword,
                        child: const Text('Cambiar Contraseña'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}