import 'package:flutter/material.dart';
import 'package:mobile_app/models/estadisticas_model.dart';

class TablaEstadoReportes extends StatelessWidget {
  final List<DatoGrafico> datos;

  const TablaEstadoReportes({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    double total = 0;
    for (var d in datos) { total += d.value; }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.verified_outlined, color: theme.colorScheme.tertiary),
                const SizedBox(width: 8),
                Text(
                  'Efectividad y Calidad',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(theme.colorScheme.tertiaryContainer.withOpacity(0.3)),
                columnSpacing: 16,
                columns: const [
                  DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Cant.', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                  DataColumn(label: Text('%', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                ],
                rows: datos.map((dato) {
                  final porcentaje = total == 0 ? 0 : (dato.value / total * 100);
                  return DataRow(cells: [
                    DataCell(Row(
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: _getEstadoColor(dato.name), shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text(_formatEstado(dato.name)),
                      ],
                    )),
                    DataCell(Text(dato.value.toInt().toString())),
                    DataCell(Text('${porcentaje.toStringAsFixed(0)}%')),
                  ]);
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // EXPLICACIÓN DETALLADA
            _buildDetailedExplanation(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedExplanation(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "¿Qué muestra esta tabla?",
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "Desglosa el ciclo de vida de tus reportes. Un alto porcentaje de reportes 'Verificados' indica que tus contribuciones son precisas y valiosas para la comunidad.",
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'verificado': return Colors.green;
      case 'rechazado': return Colors.red;
      case 'pendiente_verificacion': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String _formatEstado(String estadoRaw) {
    switch (estadoRaw) {
      case 'pendiente_verificacion': return 'Pendiente';
      case 'verificado': return 'Verificado';
      case 'rechazado': return 'Rechazado';
      case 'fusionado': return 'Fusionado';
      case 'oculto': return 'Oculto';
      default: return estadoRaw;
    }
  }
}