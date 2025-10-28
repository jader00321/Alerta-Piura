import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile_app/api/analiticas_service.dart';
import 'package:mobile_app/models/estadisticas_model.dart';
import 'package:mobile_app/services/servicio_pdf.dart';
import 'package:open_file/open_file.dart';

/// Clase auxiliar para agrupar los datos cargados para las analíticas.
class AnaliticasData {
  final List<DatoGrafico> porCategoria;
  final List<DatoGrafico> porDistrito;
  final List<DatoGrafico> tendencia;
  AnaliticasData(
      {required this.porCategoria,
      required this.porDistrito,
      required this.tendencia});
}

/// {@template pantalla_panel_analitico}
/// Pantalla que muestra gráficos analíticos globales (función Premium/Reportero).
///
/// Obtiene datos agregados de [AnaliticasService] y los muestra usando [fl_chart].
/// Permite generar y guardar un informe PDF de los datos mostrados
/// utilizando [ServicioPdf].
/// {@endtemplate}
class PantallaPanelAnalitico extends StatefulWidget {
  /// {@macro pantalla_panel_analitico}
  const PantallaPanelAnalitico({super.key});
  @override
  State<PantallaPanelAnalitico> createState() =>
      _PantallaPanelAnaliticoState();
}

/// Estado para [PantallaPanelAnalitico].
///
/// Maneja la carga de los datos analíticos y la generación del PDF.
class _PantallaPanelAnaliticoState extends State<PantallaPanelAnalitico> {
  final AnaliticasService _analiticasService = AnaliticasService();
  final ServicioPdf _pdfService = ServicioPdf();
  
  /// Futuro que contiene los datos combinados para los gráficos.
  late Future<AnaliticasData> _analyticsFuture;
  /// Indica si se está generando el archivo PDF.
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _analyticsFuture = _loadAllAnalytics();
  }

  /// Carga simultáneamente todos los datos necesarios para los gráficos.
  Future<AnaliticasData> _loadAllAnalytics() async {
    // Se usan Futures en paralelo para optimizar la carga
    final results = await Future.wait([
      _analiticasService.getReportesPorCategoria(),
      _analiticasService.getReportesPorDistrito(),
      _analiticasService.getTendenciaReportes(),
    ]);
    return AnaliticasData(
      porCategoria: results[0],
      porDistrito: results[1],
      tendencia: results[2],
    );
  }

  /// Genera el informe PDF usando [ServicioPdf], lo guarda localmente
  /// y ofrece abrirlo.
  Future<void> _handleExportPDF(AnaliticasData data) async {
    setState(() => _isExporting = true);

    try {
      final file = await _pdfService.generarInformeAnalitico(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Informe guardado en "Mis Informes"'),
            action: SnackBarAction(
              label: 'Abrir',
              onPressed: () => OpenFile.open(file.path),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al generar PDF: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Analítico'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _analyticsFuture = _loadAllAnalytics();
              });
            },
            tooltip: 'Refrescar datos',
          ),
        ],
      ),
      body: FutureBuilder<AnaliticasData>(
        future: _analyticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error al cargar analíticas: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(
                child: Text('No hay datos analíticos disponibles.'));
          }

          final data = snapshot.data!;
          // Muestra los gráficos en un ListView
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildTrendChart(context, data.tendencia),
              const SizedBox(height: 24),
              _buildCategoryChart(context, data.porCategoria),
              const SizedBox(height: 24),
              _buildDistrictChart(context, data.porDistrito),
            ],
          );
        },
      ),
      floatingActionButton: FutureBuilder<AnaliticasData>(
          future: _analyticsFuture,
          builder: (context, snapshot) {
            // Muestra el FAB solo si los datos están cargados y no se está exportando
            if (snapshot.hasData && !_isExporting) {
              return FloatingActionButton.extended(
                onPressed: () => _handleExportPDF(snapshot.data!),
                label: const Text('Exportar PDF'),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                tooltip: 'Generar y guardar informe en PDF',
              );
            }
            if (_isExporting) {
              return const FloatingActionButton(
                onPressed: null,
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            return const SizedBox.shrink(); // Oculta el FAB si no hay datos
          }),
    );
  }

  /// Construye el gráfico de líneas para la tendencia.
  Widget _buildTrendChart(BuildContext context, List<DatoGrafico> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tendencia de Reportes (Últimos 30 días)',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                      show: true, border: Border.all(color: Colors.grey.shade300)),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                          show: true,
                          color: Theme.of(context).colorScheme.primary.withAlpha(51)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el gráfico de barras para categorías.
  Widget _buildCategoryChart(BuildContext context, List<DatoGrafico> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reportes por Categoría',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
                    rightTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => SideTitleWidget(
                        meta: meta,
                        child: Text(data[value.toInt()].name,
                            style: const TextStyle(fontSize: 10)),
                      ),
                      reservedSize: 30,
                    )),
                  ),
                  barGroups: data.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.value,
                          color: Colors.primaries[entry.key % Colors.primaries.length],
                          width: 16,
                          borderRadius:
                              const BorderRadius.vertical(top: Radius.circular(4)),
                        )
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el gráfico de barras para los 5 distritos principales.
  Widget _buildDistrictChart(BuildContext context, List<DatoGrafico> data) {
    // Tomar solo los 5 distritos con más reportes
    final topData = data.length > 5 ? data.sublist(0, 5) : data;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top 5 Reportes por Distrito',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
                    rightTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => SideTitleWidget(
                        meta: meta,
                        child: Text(topData[value.toInt()].name,
                            style: const TextStyle(fontSize: 10)),
                      ),
                      reservedSize: 30,
                    )),
                  ),
                  barGroups: topData.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.value,
                          color: Colors.accents[entry.key % Colors.accents.length],
                          width: 16,
                          borderRadius:
                              const BorderRadius.vertical(top: Radius.circular(4)),
                        )
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}