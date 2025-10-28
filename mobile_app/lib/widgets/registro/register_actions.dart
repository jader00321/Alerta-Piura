import 'package:flutter/material.dart';

/// {@template register_actions}
/// Widget que contiene el botón principal de acción para la pantalla de registro.
///
/// Muestra un [ElevatedButton] "Registrarse". Muestra un indicador de carga
/// ([CircularProgressIndicator]) y se deshabilita si [isLoading] es `true`.
/// {@endtemplate}
class RegisterActions extends StatelessWidget {
  /// Indica si se está procesando la solicitud de registro.
  final bool isLoading;
  /// Callback que se ejecuta al presionar el botón "Registrarse".
  final VoidCallback onSubmit;

  /// {@macro register_actions}
  const RegisterActions({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    /// Botón principal para enviar el formulario de registro.
    return ElevatedButton(
      // Deshabilitado si isLoading es true.
      onPressed: isLoading ? null : onSubmit,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          // Muestra un spinner si está cargando.
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
            )
          // Muestra el texto si no está cargando.
          : const Text('Registrarse'),
    );
  }
}