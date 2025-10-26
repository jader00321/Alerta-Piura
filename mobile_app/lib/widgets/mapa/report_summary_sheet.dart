import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_model.dart';

class ReportSummarySheet extends StatelessWidget {
  final Reporte reporte;

  const ReportSummarySheet({
    super.key,
    required this.reporte,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Handle" para indicar que el panel es deslizable
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

          // Información del Reporte
          Text(
            reporte.titulo,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text(reporte.categoria),
            backgroundColor: theme.colorScheme.secondaryContainer,
            labelStyle:
                TextStyle(color: theme.colorScheme.onSecondaryContainer),
          ),
          const SizedBox(height: 16),

          if (reporte.descripcion != null && reporte.descripcion!.isNotEmpty)
            Text(
              reporte.descripcion!,
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

          const Divider(height: 32),

          // Botón de Acción Principal
          ElevatedButton(
            onPressed: () {
              // Cierra el BottomSheet primero
              Navigator.pop(context);
              // Luego navega a la pantalla de detalles completos
              Navigator.pushNamed(context, '/reporte_detalle',
                  arguments: reporte.id);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
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
