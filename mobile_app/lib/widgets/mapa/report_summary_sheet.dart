import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_model.dart';

/// {@template report_summary_sheet}
/// Panel modal inferior ([ModalBottomSheet]) que muestra un resumen rápido
/// de un [Reporte] cuando se toca un marcador en [MapaView].
///
/// Muestra título, categoría y un extracto de la descripción.
/// Contiene un botón "Ver Detalles" que navega a la pantalla completa
/// [ReporteDetalleScreen] pasando el ID del reporte.
/// {@endtemplate}
class ReportSummarySheet extends StatelessWidget {
  /// El reporte (modelo básico) cuyos datos se mostrarán.
  final Reporte reporte;

  /// {@macro report_summary_sheet}
  const ReportSummarySheet({
    super.key,
    required this.reporte,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      // Padding interno para el contenido.
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ajusta la altura al contenido.
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// "Handle" visual para indicar que el panel es deslizable.
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          /// Título del reporte.
          Text(
            reporte.titulo,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          /// Chip de Categoría.
          Chip(
            label: Text(reporte.categoria),
            backgroundColor: theme.colorScheme.secondaryContainer,
            labelStyle:
                TextStyle(color: theme.colorScheme.onSecondaryContainer),
          ),
          const SizedBox(height: 16),

          /// Extracto de la descripción (si existe).
          if (reporte.descripcion != null && reporte.descripcion!.isNotEmpty)
            Text(
              reporte.descripcion!,
              style: theme.textTheme.bodyMedium,
              maxLines: 3, // Limita a 3 líneas.
              overflow: TextOverflow.ellipsis,
            ),

          const Divider(height: 32),

          /// Botón de acción principal para ver detalles.
          ElevatedButton(
            onPressed: () {
              // Cierra el BottomSheet primero.
              Navigator.pop(context);
              // Luego navega a la pantalla de detalles completos.
              Navigator.pushNamed(context, '/reporte_detalle',
                  arguments: reporte.id);
            },
            style: ElevatedButton.styleFrom(
              minimumSize:
                  const Size(double.infinity, 50), // Botón de ancho completo.
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Ver Detalles y Comentarios'),
          )
        ],
      ),
    );
  }
}