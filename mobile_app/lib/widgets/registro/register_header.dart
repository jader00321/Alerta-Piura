import 'package:flutter/material.dart';

/// {@template register_header}
/// Widget que muestra el título y subtítulo en la parte superior
/// de la pantalla de registro ([RegisterScreen]).
/// {@endtemplate}
class RegisterHeader extends StatelessWidget {
  /// {@macro register_header}
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        /// Título principal.
        Text(
          'Únete a la comunidad',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        /// Subtítulo descriptivo.
        Text(
          'Crea tu cuenta para empezar a reportar',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}