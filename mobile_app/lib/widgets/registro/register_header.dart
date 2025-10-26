import 'package:flutter/material.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          'Únete a la comunidad',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          'Crea tu cuenta para empezar a reportar',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
