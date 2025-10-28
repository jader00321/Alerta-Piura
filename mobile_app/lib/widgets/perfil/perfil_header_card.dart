import 'package:flutter/material.dart';
import 'package:mobile_app/models/perfil_model.dart';

/// {@template perfil_header_card}
/// Tarjeta principal que muestra la información de cabecera del usuario
/// en la pantalla de perfil ([PerfilScreen]).
///
/// Muestra un [CircleAvatar] con las iniciales del usuario, el nombre o alias,
/// el email y el total de puntos acumulados.
/// {@endtemplate}
class PerfilHeaderCard extends StatelessWidget {
  /// Los datos del perfil del usuario a mostrar.
  final Perfil perfil;

  /// {@macro perfil_header_card}
  const PerfilHeaderCard({super.key, required this.perfil});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Determina la inicial a mostrar en el avatar (alias o nombre).
    final String inicial = perfil.alias?.isNotEmpty == true
        ? perfil.alias![0].toUpperCase()
        : perfil.nombre[0].toUpperCase();

    return Card(
      elevation: 6, // Sombra pronunciada para destacar.
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0), // Padding generoso.
        child: Column(
          children: [
            /// Avatar del usuario con la inicial.
            CircleAvatar(
              radius: 50, // Tamaño grande.
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                inicial,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 16),
            /// Nombre (o Alias si existe) del usuario.
            Text(
              perfil.alias ?? perfil.nombre, // Muestra alias si existe, si no, nombre.
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            /// Email del usuario.
            Text(perfil.email,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 24),
            /// Fila que muestra los Puntos de Comunidad.
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