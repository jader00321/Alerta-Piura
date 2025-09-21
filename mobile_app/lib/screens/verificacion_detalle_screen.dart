import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mobile_app/api/lider_service.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:mobile_app/models/reporte_detallado_model.dart';

class VerificacionDetalleScreen extends StatefulWidget {
  final int reporteId;
  const VerificacionDetalleScreen({super.key, required this.reporteId});

  @override
  State<VerificacionDetalleScreen> createState() => _VerificacionDetalleScreenState();
}

class _VerificacionDetalleScreenState extends State<VerificacionDetalleScreen> {
  final ReporteService _reporteService = ReporteService();
  final LiderService _liderService = LiderService();
  late Future<ReporteDetallado> _reporteFuture;

  @override
  void initState() {
    super.initState();
    _reporteFuture = _reporteService.getReporteById(widget.reporteId);
  }

  Future<void> _moderarReporte(bool aprobar) async {
    final success = aprobar
        ? await _liderService.aprobarReporte(widget.reporteId)
        : await _liderService.rechazarReporte(widget.reporteId);
    
    if (mounted && success) {
      Navigator.pop(context, true); // Pop with 'true' to signal a refresh
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al moderar el reporte')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificar Reporte')),
      body: FutureBuilder<ReporteDetallado>(
        future: _reporteFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final reporte = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    if (reporte.fotoUrl != null)
                      Image.network(reporte.fotoUrl!, height: 250, fit: BoxFit.cover),
                    
                    // --- MINIMAP SECTION ---
                    SizedBox(
                      height: 200,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: reporte.location,
                          initialZoom: 16.0,
                          interactionOptions: const InteractionOptions(flags: InteractiveFlag.none), // Non-interactive
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.mobile_app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: reporte.location,
                                width: 80,
                                height: 80,
                                child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Chip(
                            label: Text(reporte.categoria),
                            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                          ),
                          const SizedBox(height: 8),
                          Text(reporte.titulo, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Publicado por: ${reporte.autor}'),
                          Text('Fecha: ${reporte.fechaCreacion}'),
                          const Divider(height: 24),
                          Text('Descripción:', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(reporte.descripcion ?? 'Sin descripción.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Aprobar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                onPressed: () => _moderarReporte(true),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Rechazar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () => _moderarReporte(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}