import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/models/estadisticas_model.dart';

class TarjetaAnaliticaDistritos extends StatelessWidget {
  final List<DatoGrafico> datos;

  const TarjetaAnaliticaDistritos({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (datos.isEmpty) return const SizedBox.shrink();
    final chartData = _processData(datos);

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Reportes por Distrito", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 30,
                        sections: chartData.asMap().entries.map((entry) {
                          final index = entry.key;
                          final data = entry.value;
                          return PieChartSectionData(
                            color: Colors.accents[index % Colors.accents.length],
                            value: data.value,
                            title: '${data.value.toInt()}',
                            radius: 45,
                            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: chartData.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          children: [
                            Container(width: 10, height: 10, color: Colors.accents[entry.key % Colors.accents.length]),
                            const SizedBox(width: 4),
                            Expanded(child: Text(entry.value.name, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // --- DESCRIPCIÓN AÑADIDA ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Desglose porcentual de la actividad por zonas geográficas. Permite comparar qué distritos tienen mayor participación ciudadana o mayor número de incidencias.",
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DatoGrafico> _processData(List<DatoGrafico> raw) {
    if (raw.length <= 5) return raw;
    final top4 = raw.take(4).toList();
    final others = raw.skip(4).toList();
    double othersSum = 0;
    for (var d in others) othersSum += d.value;
    if (othersSum > 0) top4.add(DatoGrafico(name: 'Otros', value: othersSum));
    return top4;
  }
}