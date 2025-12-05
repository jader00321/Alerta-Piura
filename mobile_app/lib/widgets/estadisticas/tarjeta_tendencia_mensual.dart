import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/models/estadisticas_model.dart';

class TarjetaTendenciaMensual extends StatelessWidget {
  final List<DatoGrafico> datos;

  const TarjetaTendenciaMensual({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (datos.isEmpty) return const SizedBox.shrink();

    // Preparar datos para el gráfico de línea
    List<FlSpot> spots = [];
    for (int i = 0; i < datos.length; i++) {
      spots.add(FlSpot(i.toDouble(), datos[i].value));
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Tendencia de Actividad',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 1.5, // Ligeramente más alto para acomodar etiquetas
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0, left: 6.0, bottom: 0),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: theme.dividerColor.withOpacity(0.5),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      
                      // --- EJE X (Inferior) ---
                      bottomTitles: AxisTitles(
                        // Título del Eje X
                        axisNameWidget: Text(
                          'Meses',
                          style: TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary
                          ),
                        ),
                        axisNameSize: 22, // Espacio reservado para el título "Meses"
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32, // Espacio para las etiquetas de los meses
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= datos.length) return const SizedBox.shrink();
                            // Mostrar solo el mes (ej. "2025-10" -> "10")
                            final nombreCompleto = datos[index].name;
                            final etiqueta = nombreCompleto.length > 5 
                                ? nombreCompleto.substring(5) 
                                : nombreCompleto;
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                etiqueta, 
                                style: TextStyle(
                                  fontSize: 11, 
                                  color: theme.textTheme.bodyMedium?.color
                                )
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // --- EJE Y (Izquierdo) ---
                      leftTitles: AxisTitles(
                        // Título del Eje Y
                        axisNameWidget: const Text(
                          'Nº Reportes',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        axisNameSize: 20, // Espacio reservado para el título vertical
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1, // Mostrar enteros en el eje Y
                          reservedSize: 28, // Espacio para los números (1, 2, 3...)
                          getTitlesWidget: (value, meta) {
                             if (value % 1 != 0) return const SizedBox.shrink(); // Solo enteros
                             return Text(
                               value.toInt().toString(), 
                               style: const TextStyle(fontSize: 11, color: Colors.grey),
                               textAlign: TextAlign.left,
                             );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: datos.length.toDouble() - 1,
                    minY: 0,
                    maxY: _getMaxValue() + 1,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: theme.colorScheme.primary,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: theme.colorScheme.primary,
                              strokeWidth: 2,
                              strokeColor: theme.cardColor,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: theme.colorScheme.primary.withOpacity(0.15),
                        ),
                      ),
                    ],
                  ),
                ),
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
            "Muestra la cantidad de reportes que has realizado en los últimos meses. El eje vertical indica el número de reportes y el horizontal los meses del año.",
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  double _getMaxValue() {
    double max = 0;
    for (var d in datos) {
      if (d.value > max) max = d.value;
    }
    return max == 0 ? 5 : max; // Mínimo 5 para que el gráfico no se vea aplastado si es 0
  }
}