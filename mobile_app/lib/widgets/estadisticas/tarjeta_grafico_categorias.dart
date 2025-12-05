import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/models/estadisticas_model.dart';

class TarjetaGraficoCategorias extends StatefulWidget {
  final List<DatoGrafico> datos;

  const TarjetaGraficoCategorias({super.key, required this.datos});

  @override
  State<TarjetaGraficoCategorias> createState() => _TarjetaGraficoCategoriasState();
}

class _TarjetaGraficoCategoriasState extends State<TarjetaGraficoCategorias> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (widget.datos.isEmpty) {
      return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text("Sin datos de categorías")));
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'Distribución por Categoría',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 1.3,
              child: Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  touchedIndex = -1;
                                  return;
                                }
                                touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: _showingSections(widget.datos),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Leyenda
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.datos.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 12, height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.primaries[index % Colors.primaries.length],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  data.name,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text('(${data.value.toInt()})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
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
            "¿Qué muestra este gráfico?",
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "Identifica los tipos de problemas que reportas con más frecuencia. Te ayuda a entender en qué áreas estás enfocando tu contribución ciudadana.",
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _showingSections(List<DatoGrafico> datos) {
    return List.generate(datos.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 55.0 : 45.0;
      final data = datos[i];
      final total = datos.fold(0.0, (sum, item) => sum + item.value);
      final percentage = (data.value / total * 100).toStringAsFixed(0);
      
      return PieChartSectionData(
        color: Colors.primaries[i % Colors.primaries.length],
        value: data.value,
        title: '$percentage%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }
}