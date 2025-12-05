import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/models/estadisticas_model.dart';

class TarjetaAnaliticaTendencia extends StatelessWidget {
  final List<DatoGrafico> datos;

  const TarjetaAnaliticaTendencia({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (datos.isEmpty) return const SizedBox.shrink();

    // Crear puntos para el gráfico
    List<FlSpot> spots = datos.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    // Colores del gradiente
    List<Color> gradientColors = [
      theme.colorScheme.primary,
      theme.colorScheme.tertiary,
    ];

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.show_chart_rounded, color: theme.colorScheme.tertiary),
                    const SizedBox(width: 8),
                    const Text(
                      "Tendencia Global",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                // Chip indicador del periodo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Text(
                    "Últimos 30 días", 
                    style: TextStyle(fontSize: 10, color: theme.colorScheme.onTertiaryContainer, fontWeight: FontWeight.bold)
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),
            
            AspectRatio(
              aspectRatio: 1.6,
              child: LineChart(
                LineChartData(
                  // --- Ejes y Títulos ---
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    
                    // Eje Inferior (X)
                    bottomTitles: AxisTitles(
                      axisNameWidget: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text("Línea de Tiempo (Días)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.hintColor)),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: (datos.length / 5).ceilToDouble(), // Mostrar ~5 etiquetas
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= datos.length) return const SizedBox.shrink();
                          // Formato fecha corta: "25/10"
                          final parts = datos[index].name.split('-'); 
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "${parts[2]}/${parts[1]}",
                              style: TextStyle(fontSize: 10, color: theme.hintColor),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Eje Izquierdo (Y)
                    leftTitles: AxisTitles(
                      axisNameWidget: Text("Cant. Reportes", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.hintColor)),
                      axisNameSize: 20,
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _getInterval(spots),
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value % 1 != 0) return const SizedBox.shrink();
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: 10, color: theme.hintColor),
                            textAlign: TextAlign.right,
                          );
                        },
                      ),
                    ),
                  ),

                  // --- Estilo del Gráfico ---
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.dividerColor.withOpacity(0.5),
                      strokeWidth: 1,
                      dashArray: [5, 5], // Línea punteada
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: theme.dividerColor),
                      left: BorderSide(color: theme.dividerColor),
                    ),
                  ),
                  minX: 0,
                  maxX: datos.length.toDouble() - 1,
                  minY: 0,
                  maxY: _getMaxY(spots) * 1.2, // Espacio arriba

                  // --- Datos de la Línea ---
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true, // Curva suave
                      gradient: LinearGradient(colors: gradientColors),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: false, // Solo mostrar puntos al tocar (ver touchData)
                      ),
                      // Área sombreada debajo
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: gradientColors.map((color) => color.withOpacity(0.2)).toList(),
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],

                  // --- Tooltip al Tocar ---
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (spot) => isDark ? Colors.grey.shade800 : Colors.white,
                      tooltipBorder: BorderSide(color: theme.colorScheme.primary),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          final fecha = datos[index].name;
                          return LineTooltipItem(
                            "$fecha\n",
                            TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: "${spot.y.toInt()} Reportes",
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                    handleBuiltInTouches: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // --- Descripción ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.insights, size: 18, color: theme.colorScheme.tertiary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Refleja la actividad diaria de reportes en la ciudad. Los picos indican días con mayor incidencia o participación ciudadana.",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxY(List<FlSpot> spots) {
    double max = 0;
    for (var spot in spots) {
      if (spot.y > max) max = spot.y;
    }
    return max == 0 ? 5 : max;
  }

  double _getInterval(List<FlSpot> spots) {
    final max = _getMaxY(spots);
    if (max <= 5) return 1;
    if (max <= 10) return 2;
    return 5;
  }
}