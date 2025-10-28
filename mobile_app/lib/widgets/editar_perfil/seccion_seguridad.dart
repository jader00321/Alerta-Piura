import 'package:flutter/material.dart';
import 'package:mobile_app/api/perfil_service.dart';

/// {@template seccion_seguridad}
/// Widget [StatefulWidget] que encapsula el formulario para cambiar la
/// contraseña del usuario.
///
/// Se utiliza dentro de [EditarPerfilScreen].
/// Requiere la contraseña actual, la nueva contraseña y la confirmación.
/// Maneja su propio [FormKey], [TextEditingController]s y el estado de
/// visibilidad de la contraseña ([_obscureText]).
/// Llama a [PerfilService.updateMyPassword] para realizar el cambio.
/// {@endtemplate}
class SeccionSeguridad extends StatefulWidget {
  /// {@macro seccion_seguridad}
  const SeccionSeguridad({super.key});

  @override
  State<SeccionSeguridad> createState() => _SeccionSeguridadState();
}

/// Estado para [SeccionSeguridad].
class _SeccionSeguridadState extends State<SeccionSeguridad> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _perfilService = PerfilService();

  /// Controla si los campos de contraseña ocultan el texto.
  bool _obscureText = true;
  /// Indica si se está procesando el guardado de la nueva contraseña.
  bool _isSaving = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Valida el formulario y envía la solicitud de cambio de contraseña a la API.
  ///
  /// Muestra un [SnackBar] con el resultado (éxito o error).
  /// Limpia todos los campos del formulario si la actualización es exitosa.
  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate() && !_isSaving) {
      setState(() => _isSaving = true);

      /// Llama al servicio de perfil con la contraseña actual y la nueva.
      final response = await _perfilService.updateMyPassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      if (mounted) {
        /// Muestra el mensaje de la API (ej. "Contraseña actualizada" o "Contraseña actual incorrecta").
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['data']['message']),
          backgroundColor:
              response['statusCode'] == 200 ? Colors.green : Colors.red,
        ));

        /// Si tuvo éxito, limpia los campos.
        if (response['statusCode'] == 200) {
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          _formKey.currentState?.reset();
        }
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Seguridad', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              /// Campo Contraseña Actual.
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureText,
                decoration: const InputDecoration(
                    labelText: 'Contraseña Actual',
                    border: OutlineInputBorder()),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              /// Campo Nueva Contraseña.
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Nueva Contraseña',
                  border: const OutlineInputBorder(),
                  /// Botón para alternar visibilidad de contraseña.
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
                ),
                validator: (value) => (value?.length ?? 0) < 6
                    ? 'Debe tener al menos 6 caracteres'
                    : null,
              ),
              const SizedBox(height: 16),
              /// Campo Confirmar Nueva Contraseña.
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
              /// Botón de acción para guardar.
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