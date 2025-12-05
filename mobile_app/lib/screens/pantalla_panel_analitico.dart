import 'package:flutter/material.dart';
import 'package:mobile_app/api/analiticas_service.dart';
import 'package:mobile_app/models/analiticas_dashboard_data.dart'; // <-- IMPORTAR EL NUEVO MODELO
import 'package:mobile_app/models/analiticas_reportero_model.dart';
import 'package:mobile_app/models/estadisticas_model.dart';
import 'package:mobile_app/services/servicio_pdf.dart';
import 'package:open_file/open_file.dart';

// Importación de Widgets Modulares
import 'package:mobile_app/widgets/analiticas/tarjeta_indicador_eficiencia.dart';
import 'package:mobile_app/widgets/analiticas/tarjeta_torta_urgencia.dart';
import 'package:mobile_app/widgets/analiticas/tarjeta_mapa_calor.dart';
import 'package:mobile_app/widgets/analiticas/tarjeta_analitica_categorias.dart';
import 'package:mobile_app/widgets/analiticas/tarjeta_analitica_distritos.dart';
import 'package:mobile_app/widgets/analiticas/tarjeta_analitica_tendencia.dart';

class PantallaPanelAnalitico extends StatefulWidget {
  const PantallaPanelAnalitico({super.key});

  @override
  State<PantallaPanelAnalitico> createState() => _PantallaPanelAnaliticoState();
}

class _PantallaPanelAnaliticoState extends State<PantallaPanelAnalitico> {
  final AnaliticasService _service = AnaliticasService();
  final ServicioPdf _pdfService = ServicioPdf();
  
  late Future<AnaliticasDashboardData> _dashboardFuture;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadAllAnalytics();
  }

  void _loadAllAnalytics() {
    setState(() {
      _dashboardFuture = _fetchAllData();
    });
  }

  Future<AnaliticasDashboardData> _fetchAllData() async {
    try {
      final results = await Future.wait([
        _service.getReportesPorCategoria(), // 0
        _service.getReportesPorDistrito(),  // 1
        _service.getTendenciaReportes(),    // 2
        _service.getReportesPorUrgencia(),  // 3
        _service.getTiemposAtencion(),      // 4
        _service.getMapaCalor(),            // 5
      ]);

      return AnaliticasDashboardData(
        porCategoria: results[0] as List<DatoGrafico>,
        porDistrito: results[1] as List<DatoGrafico>,
        tendencia: results[2] as List<DatoGrafico>,
        porUrgencia: results[3] as List<DatoGrafico>,
        eficiencia: results[4] as TiemposAtencion,
        mapaCalor: results[5] as List<PuntoMapaCalor>,
      );
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _handleExportPDF(AnaliticasDashboardData data) async {
    setState(() => _isExporting = true);
    try {
      // Ahora pasamos el objeto COMPLETO al servicio PDF
      final file = await _pdfService.generarInformeAnalitico(data);
      
      // Registrar en backend
      _service.solicitarExportacionPDF();

      await OpenFile.open(file.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exportando PDF: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Prensa y Datos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllAnalytics,
            tooltip: 'Actualizar datos',
          )
        ],
      ),
      body: FutureBuilder<AnaliticasDashboardData>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadAllAnalytics,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Eficiencia
                TarjetaIndicadorEficiencia(tiempos: data.eficiencia),
                const SizedBox(height: 16),
                
                // 2. Mapa de Calor
                TarjetaMapaCalor(puntos: data.mapaCalor),
                const SizedBox(height: 16),

                // 3. Categorías y Urgencia
                LayoutBuilder(builder: (context, constraints) {
                   if (constraints.maxWidth > 600) {
                     return Row(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Expanded(child: TarjetaAnaliticaCategorias(datos: data.porCategoria)),
                         const SizedBox(width: 16),
                         Expanded(child: TarjetaTortaUrgencia(datos: data.porUrgencia)),
                       ],
                     );
                   }
                   return Column(
                     children: [
                       TarjetaAnaliticaCategorias(datos: data.porCategoria),
                       const SizedBox(height: 16),
                       TarjetaTortaUrgencia(datos: data.porUrgencia),
                     ],
                   );
                }),
                
                const SizedBox(height: 16),
                
                // 4. Distritos y Tendencia
                TarjetaAnaliticaDistritos(datos: data.porDistrito),
                const SizedBox(height: 16),
                TarjetaAnaliticaTendencia(datos: data.tendencia),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isExporting 
          ? null 
          : () async {
              final data = await _dashboardFuture;
              _handleExportPDF(data);
            },
        icon: _isExporting 
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
          : const Icon(Icons.picture_as_pdf),
        label: Text(_isExporting ? 'Generando...' : 'Exportar Informe'),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }
}