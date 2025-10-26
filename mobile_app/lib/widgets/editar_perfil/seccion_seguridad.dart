import 'package:flutter/material.dart';
import 'package:mobile_app/api/perfil_service.dart';

class SeccionSeguridad extends StatefulWidget {
  const SeccionSeguridad({super.key});

  @override
  State<SeccionSeguridad> createState() => _SeccionSeguridadState();
}

class _SeccionSeguridadState extends State<SeccionSeguridad> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _perfilService = PerfilService();
  bool _obscureText = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate() && !_isSaving) {
      setState(() => _isSaving = true);

      final response = await _perfilService.updateMyPassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['data']['message']),
          backgroundColor:
              response['statusCode'] == 200 ? Colors.green : Colors.red,
        ));
        if (response['statusCode'] == 200) {
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          FocusScope.of(context).unfocus();
        }
      }
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Seguridad', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureText,
                decoration: const InputDecoration(
                    labelText: 'Contraseña Actual',
                    border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'La contraseña actual es requerida' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Nueva Contraseña',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                  ),
                ),
                validator: (value) => (value?.length ?? 0) < 6
                    ? 'Debe tener al menos 6 caracteres'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureText,
                decoration: const InputDecoration(
                    labelText: 'Confirmar Nueva Contraseña',
                    border: OutlineInputBorder()),
                validator: (value) => value != _newPasswordController.text
                    ? 'Las contraseñas no coinciden'
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _updatePassword,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Cambiar Contraseña'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
