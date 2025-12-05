import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/models/estadisticas_model.dart';

class TarjetaTortaUrgencia extends StatelessWidget {
  final List<DatoGrafico> datos;

  const TarjetaTortaUrgencia({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (datos.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Nivel de Urgencia", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 35,
                  sections: datos.map((d) {
                    final color = _getColor(d.name);
                    return PieChartSectionData(
                      color: color,
                      value: d.value,
                      title: '${d.value.toInt()}',
                      radius: 45,
                      titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: datos.map((d) => Row(
                children: [
                  Container(width: 12, height: 12, color: _getColor(d.name), margin: const EdgeInsets.only(right: 4)),
                  Text(d.name, style: const TextStyle(fontSize: 12)),
                ],
              )).toList(),
            ),
            const SizedBox(height: 16),
            // DESCRIPCIÓN
             Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Clasificación de los reportes según la gravedad percibida. Ayuda a identificar si la ciudad enfrenta problemas críticos (Alta) o de mantenimiento rutinario.",
                style: TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(String urgencia) {
    switch (urgencia.toLowerCase()) {
      case 'alta': return Colors.red;
      case 'media': return Colors.orange;
      default: return Colors.green;
    }
  }
}