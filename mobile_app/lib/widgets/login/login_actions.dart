import 'package:flutter/material.dart';

/// {@template login_actions}
/// Widget que contiene los botones de acción principales para la pantalla de login [LoginScreen].
///
/// Incluye el botón "Iniciar Sesión" (con estado de carga) y un [TextButton]
/// que navega a la pantalla de registro (`/register`).
/// {@endtemplate}
class LoginActions extends StatelessWidget {
  /// Indica si se está procesando el inicio de sesión.
  /// Cuando es `true`, el botón "Iniciar Sesión" se deshabilita y muestra un spinner.
  final bool isLoading;
  /// Callback que se ejecuta al presionar el botón "Iniciar Sesión".
  /// Típicamente, inicia la validación del formulario y la llamada a la API.
  final VoidCallback onSubmit;

  /// {@macro login_actions}
  const LoginActions({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        /// Botón principal para enviar el formulario de login.
        ElevatedButton(
          onPressed: isLoading ? null : onSubmit,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: isLoading
              /// Muestra un spinner si está cargando.
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 3, color: Colors.white),
                )
              /// Muestra el texto si no está cargando.
              : const Text('Iniciar Sesión'),
        ),
        const SizedBox(height: 20),
        /// Fila con el enlace a la pantalla de registro.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("¿No tienes una cuenta?"),
            TextButton(
              onPressed: () {
                // Evita la navegación si ya se está procesando un login.
                if (!isLoading) {
                  Navigator.pushNamed(context, '/register');
                }
              },
              child: const Text('Regístrate aquí'),
            ),
          ],
        ),
      ],
    );
  }
}