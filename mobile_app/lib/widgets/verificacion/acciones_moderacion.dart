import 'package:flutter/material.dart';

/// {@template acciones_moderacion}
/// Barra inferior con las acciones principales de moderación para un reporte pendiente.
///
/// Muestra botones para Rechazar, Fusionar y Aprobar el reporte.
/// Muestra un indicador de carga y deshabilita los botones mientras
/// se procesa una acción ([isLoading]).
/// {@endtemplate}
class AccionesModeracion extends StatelessWidget {
  /// Indica si se está procesando una acción de moderación.
  final bool isLoading;
  /// Callback que se ejecuta al presionar Aprobar (`true`) o Rechazar (`false`).
  final Function(bool) onModerar;
  /// Callback que se ejecuta al presionar el botón Fusionar.
  final VoidCallback onFusionar;

  /// {@macro acciones_moderacion}
  const AccionesModeracion({
    super.key,
    required this.isLoading,
    required this.onModerar,
    required this.onFusionar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BottomAppBar(
      elevation: 8.0,
      surfaceTintColor: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            /// Botón para rechazar el reporte.
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Rechazar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: isLoading ? null : () => onModerar(false),
              ),
            ),
            const SizedBox(width: 8),

            /// Botón para iniciar el flujo de fusión del reporte.
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.merge_type_outlined),
                label: const Text('Fusionar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.secondary,
                  side: BorderSide(color: theme.colorScheme.secondary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: isLoading ? null : onFusionar,
              ),
            ),
            const SizedBox(width: 8),

            /// Botón para aprobar el reporte. Muestra un spinner si [isLoading] es true.
            Expanded(
              child: ElevatedButton.icon(
                icon: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: theme.colorScheme.onPrimary, strokeWidth: 2))
                    : const Icon(Icons.check_circle_outline),
                label: const Text('Aprobar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
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