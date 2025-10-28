import 'package:flutter/material.dart';
import 'package:mobile_app/api/perfil_service.dart';
import 'package:mobile_app/models/estadisticas_model.dart';
import 'package:fl_chart/fl_chart.dart';

/// {@template pantalla_estadisticas_personales}
/// Pantalla que muestra estadísticas personalizadas para el usuario (Premium).
///
/// Incluye un resumen de la actividad total y un gráfico de torta
/// mostrando la distribución de reportes por categoría.
/// {@endtemplate}
class PantallaEstadisticasPersonales extends StatefulWidget {
  /// {@macro pantalla_estadisticas_personales}
  const PantallaEstadisticasPersonales({super.key});

  @override
  State<PantallaEstadisticasPersonales> createState() =>
      _PantallaEstadisticasPersonalesState();
}

/// Estado para [PantallaEstadisticasPersonales].
///
/// Maneja la carga de los datos estadísticos desde [PerfilService].
class _PantallaEstadisticasPersonalesState
    extends State<PantallaEstadisticasPersonales> {
  /// Futuro que contiene un mapa con el resumen y los datos por categoría.
  late Future<Map<String, dynamic>> _estadisticasFuture;
  final PerfilService _perfilService = PerfilService();

  @override
  void initState() {
    super.initState();
    _estadisticasFuture = _cargarTodasLasEstadisticas();
  }

  /// Carga simultáneamente el resumen de actividad y los reportes por categoría.
  Future<Map<String, dynamic>> _cargarTodasLasEstadisticas() async {
    try {
      final resumen = await _perfilService.getMisEstadisticasResumen();
      final porCategoria = await _perfilService.getMisReportesPorCategoria();
      return {
        'resumen': resumen,
        'porCategoria': porCategoria,
      };
    } catch (e) {
      throw Exception('Fallo al cargar las estadísticas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Estadísticas'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _estadisticasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error al cargar estadísticas: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(
                child: Text('No hay estadísticas disponibles.'));
          }

          final resumen = snapshot.data!['resumen'] as EstadisticasResumen;
          final porCategoria =
              snapshot.data!['porCategoria'] as List<DatoGrafico>;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _ResumenCard(resumen: resumen),
              const SizedBox(height: 24),
              if (porCategoria.isNotEmpty)
                _GraficoCategorias(datos: porCategoria)
              else
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('Aún no has creado reportes.')),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Widget interno para mostrar el resumen de actividad.
class _ResumenCard extends StatelessWidget {
  final EstadisticasResumen resumen;
  const _ResumenCard({required this.resumen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumen de Actividad', style: theme.textTheme.titleLarge),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(Icons.report_problem_outlined,
                    resumen.totalReportes, 'Reportes Creados', theme),
                _buildStatItem(Icons.thumb_up_alt_outlined, resumen.totalApoyos,
                    'Apoyos Dados', theme),
                _buildStatItem(Icons.comment_outlined, resumen.totalComentarios,
                    'Comentarios', theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, int count, String label, ThemeData theme) {
    return Column(
      children: [
        Icon(icon, size: 32, color: theme.colorScheme.primary),
        const SizedBox(height: 8),
        Text(count.toString(),
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

/// Widget interno para mostrar el gráfico de torta de categorías.
class _GraficoCategorias extends StatelessWidget {
  final List<DatoGrafico> datos;
  const _GraficoCategorias({required this.datos});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mis Reportes por Categoría', style: theme.textTheme.titleLarge),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: datos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final dato = entry.value;
                    return PieChartSectionData(
                      color: Colors.primaries[index % Colors.primaries.length],
                      value: dato.value,
                      title: '${dato.value.toInt()}',
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: datos.asMap().entries.map((entry) {
                return _Indicator(
                  color: Colors.primaries[entry.key % Colors.primaries.length],
                  text: entry.value.name,
                  isSquare: false,
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}

/// Leyenda para el gráfico.
class _Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  const _Indicator({required this.color, required this.text, this.isSquare = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12))
      ],
    );
  }
}