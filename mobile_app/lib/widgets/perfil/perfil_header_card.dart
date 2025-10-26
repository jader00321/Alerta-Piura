import 'package:flutter/material.dart';
import 'package:mobile_app/models/perfil_model.dart';

class PerfilHeaderCard extends StatelessWidget {
  final Perfil perfil;

  const PerfilHeaderCard({super.key, required this.perfil});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                perfil.alias?[0].toUpperCase() ??
                    perfil.nombre[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              perfil.alias ?? perfil.nombre,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(perfil.email,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 30),
                const SizedBox(width: 8),
                Text(
                  '${perfil.puntos} Puntos',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
