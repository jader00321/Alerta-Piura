import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/models/estadisticas_model.dart';

class TarjetaAnaliticaCategorias extends StatelessWidget {
  final List<DatoGrafico> datos;

  const TarjetaAnaliticaCategorias({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Tomamos el Top 5 y ordenamos por valor descendente
    final topData = datos.take(5).toList();
    // Calculamos el máximo para dibujar el fondo de la barra
    final double maxValue = _getMaxValue(topData);
    
    if (topData.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  "Top 5 Problemas en Piura",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 32), // Espacio extra para los números arriba
            AspectRatio(
              aspectRatio: 1.4,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue * 1.15, // Espacio para el indicador numérico
                  barTouchData: BarTouchData(
                    enabled: false, // Desactivamos el touch default porque mostramos los números siempre
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.transparent,
                      tooltipPadding: EdgeInsets.zero,
                      tooltipMargin: 0, // Ajustar margen para que quede pegado a la barra
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          rod.toY.round().toString(),
                          TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    // Ocultar ejes innecesarios
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    // Eje Inferior (Nombres)
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value < 0 || value >= topData.length) return const SizedBox.shrink();
                          
                          final nombre = topData[value.toInt()].name;
                          // Lógica para dividir nombres largos en dos líneas si es necesario
                          final displayName = nombre.length > 10 
                              ? '${nombre.substring(0, 8)}...' 
                              : nombre;

                          return SideTitleWidget(
                            meta: meta,
                            space: 8, // Espacio entre barra y texto
                            child: Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 10, 
                                color: theme.textTheme.bodyMedium?.color,
                                fontWeight: FontWeight.w500
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: topData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    
                    return BarChartGroupData(
                      x: index,
                      // Esto hace que el tooltip (el número) se muestre siempre
                      showingTooltipIndicators: [0], 
                      barRods: [
                        BarChartRodData(
                          toY: data.value,
                          color: Colors.primaries[index % Colors.primaries.length],
                          width: 22,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          // EL FONDO "TRACK" QUE PEDISTE
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxValue, // Altura completa
                            color: isDark 
                                ? Colors.white.withOpacity(0.05) 
                                : Colors.grey.shade100, // Gris suave en modo claro
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
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
                "Estas son las categorías con mayor incidencia reportada. La barra gris indica el volumen máximo registrado para comparar la magnitud relativa.",
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxValue(List<DatoGrafico> data) {
    double max = 0;
    for (var d in data) {
      if (d.value > max) max = d.value;
    }
    return max == 0 ? 10 : max;
  }
}