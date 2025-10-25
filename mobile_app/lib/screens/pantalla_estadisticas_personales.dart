// lib/screens/pantalla_estadisticas_personales.dart

import 'package:flutter/material.dart';
import 'package:mobile_app/api/perfil_service.dart';
import 'package:mobile_app/models/estadisticas_model.dart';
import 'package:fl_chart/fl_chart.dart';

class PantallaEstadisticasPersonales extends StatefulWidget {
  const PantallaEstadisticasPersonales({super.key});

  @override
  State<PantallaEstadisticasPersonales> createState() => _PantallaEstadisticasPersonalesState();
}

class _PantallaEstadisticasPersonalesState extends State<PantallaEstadisticasPersonales> {
  late Future<Map<String, dynamic>> _estadisticasFuture;
  final PerfilService _perfilService = PerfilService();

  @override
  void initState() {
    super.initState();
    _estadisticasFuture = _cargarTodasLasEstadisticas();
  }

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
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No se encontraron datos.'));
          }

          final EstadisticasResumen resumen = snapshot.data!['resumen'];
          final List<DatoGrafico> porCategoria = snapshot.data!['porCategoria'];

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _ResumenCard(resumen: resumen),
              const SizedBox(height: 24),
              if (porCategoria.isNotEmpty)
                _GraficoCategorias(datos: porCategoria),
            ],
          );
        },
      ),
    );
  }
}

// Widget para las tarjetas de resumen
class _ResumenCard extends StatelessWidget {
  final EstadisticasResumen resumen;
  const _ResumenCard({required this.resumen});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(value: resumen.totalReportes.toString(), label: 'Reportes'),
            _StatItem(value: resumen.totalApoyos.toString(), label: 'Apoyos'),
            _StatItem(value: resumen.totalComentarios.toString(), label: 'Comentarios'),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineMedium),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

// Widget para el gráfico de Pie
class _GraficoCategorias extends StatelessWidget {
  final List<DatoGrafico> datos;
  const _GraficoCategorias({required this.datos});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mis Reportes por Categoría', style: Theme.of(context).textTheme.titleLarge),
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
        Text(text)
      ],
    );
  }
}