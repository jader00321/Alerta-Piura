// lib/widgets/verificacion/acciones_moderacion.dart
import 'package:flutter/material.dart';

class AccionesModeracion extends StatelessWidget {
  final bool isLoading;
  final Function(bool) onModerar; // true=aprobar, false=rechazar
  // --- NUEVO ---
  final VoidCallback onFusionar; // Callback para iniciar el flujo de fusión

  const AccionesModeracion({
    super.key,
    required this.isLoading,
    required this.onModerar,
    required this.onFusionar, // Añadir al constructor
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Obtener el tema actual

    return BottomAppBar(
      // Añadir elevación para destacar
      elevation: 8.0,
      surfaceTintColor: theme.colorScheme.surface, // Color de fondo
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // --- Botón Rechazar (Adaptable al Tema) ---
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Rechazar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error, // Color de error del tema
                  foregroundColor: theme.colorScheme.onError, // Color de texto sobre error
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: isLoading ? null : () => onModerar(false),
              ),
            ),
            const SizedBox(width: 8),

            // --- NUEVO: Botón Fusionar ---
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.merge_type_outlined),
                label: const Text('Fusionar'),
                 style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.secondary, // Color secundario del tema
                  side: BorderSide(color: theme.colorScheme.secondary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: isLoading ? null : onFusionar,
              ),
            ),
            // --- FIN NUEVO ---

            const SizedBox(width: 8),

            // --- Botón Aprobar (Adaptable al Tema) ---
            Expanded(
              child: ElevatedButton.icon(
                icon: isLoading
                    // Mostrar spinner si está cargando CUALQUIER acción
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: theme.colorScheme.onPrimary, strokeWidth: 2))
                    : const Icon(Icons.check_circle_outline),
                label: const Text('Aprobar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary, // Color primario del tema
                  foregroundColor: theme.colorScheme.onPrimary, // Color de texto sobre primario
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: isLoading ? null : () => onModerar(true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}