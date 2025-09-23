import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
//import 'package:latlong2/latlong.dart';
import 'package:mobile_app/api/lider_service.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:mobile_app/models/reporte_detallado_model.dart';

// We reuse the header widget for a consistent and professional design
import 'package:mobile_app/widgets/reporte_detalle/reporte_header.dart';

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
  final MapController _mapController = MapController(); // Controller for the map

  @override
  void initState() {
    super.initState();
    _reporteFuture = _reporteService.getReporteById(widget.reporteId);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _moderarReporte(bool aprobar) async {
    // This function remains the same
    final success = aprobar
        ? await _liderService.aprobarReporte(widget.reporteId)
        : await _liderService.rechazarReporte(widget.reporteId);
    
    if (mounted && success) {
      Navigator.pop(context, true);
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
            return Center(child: Text('Error al cargar el reporte para verificación: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Reporte no encontrado.'));
          }

          final reporte = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    // --- REUSE THE DETAILED HEADER WIDGET ---
                    // This now shows all the new information (urgency, district, etc.)
                    ReporteHeader(reporte: reporte),
                    
                    const Divider(height: 24),

                    // --- NEW INTERACTIVE MINIMAP SECTION ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Verificación de Ubicación', style: Theme.of(context).textTheme.titleLarge),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 250,
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: reporte.location,
                              initialZoom: 16.0,
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
                          // --- NEW MAP CONTROLS ---
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Column(
                              children: [
                                FloatingActionButton.small(
                                  heroTag: 'zoomInBtn',
                                  onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1),
                                  child: const Icon(Icons.add),
                                ),
                                const SizedBox(height: 8),
                                FloatingActionButton.small(
                                  heroTag: 'zoomOutBtn',
                                  onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1),
                                  child: const Icon(Icons.remove),
                                ),
                                const SizedBox(height: 8),
                                FloatingActionButton.small(
                                  heroTag: 'centerBtn',
                                  onPressed: () => _mapController.move(reporte.location, 16.0),
                                  child: const Icon(Icons.my_location),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24), // Extra space at the bottom
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
              // --- UPDATED BUTTONS FOR BETTER STYLING ---
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Rechazar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => _moderarReporte(false),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Aprobar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => _moderarReporte(true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}