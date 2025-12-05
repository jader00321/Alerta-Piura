import 'package:flutter/material.dart';
import 'package:mobile_app/models/estadisticas_model.dart';

class TarjetaResumenActividad extends StatelessWidget {
  final EstadisticasResumen resumen;

  const TarjetaResumenActividad({super.key, required this.resumen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen General',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildSummaryCard(
              context,
              icon: Icons.article_outlined,
              count: resumen.totalReportes,
              label: 'Reportes',
              color: Colors.blue,
            ),
            const SizedBox(width: 12),
            _buildSummaryCard(
              context,
              icon: Icons.thumb_up_outlined,
              count: resumen.totalApoyos,
              label: 'Apoyos',
              color: Colors.green,
            ),
            const SizedBox(width: 12),
            _buildSummaryCard(
              context,
              icon: Icons.comment_outlined,
              count: resumen.totalComentarios,
              label: 'Comentarios',
              color: Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Estas cifras representan tu huella total en la plataforma desde que te uniste.",
          style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, {
    required IconData icon,
    required int count,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodyMedium?.color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}