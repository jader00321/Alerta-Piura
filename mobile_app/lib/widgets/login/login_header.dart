import 'package:flutter/material.dart';

/// {@template login_header}
/// Widget que muestra la cabecera visual de la pantalla de login [LoginScreen].
///
/// Incluye el icono de la aplicación, el nombre de la app ("Reporta Piura")
/// y un mensaje de bienvenida ("Inicia sesión para continuar").
/// {@endtemplate}
class LoginHeader extends StatelessWidget {
  /// {@macro login_header}
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        /// Icono de la aplicación.
        const Icon(Icons.shield_moon_outlined, size: 80, color: Colors.teal),
        const SizedBox(height: 16),
        /// Título principal.
        Text(
          'Bienvenido a Reporta Piura',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        /// Subtítulo de bienvenida.
        Text(
          'Inicia sesión para continuar',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}