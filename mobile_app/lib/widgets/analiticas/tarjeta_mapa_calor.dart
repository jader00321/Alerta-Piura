import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/models/analiticas_reportero_model.dart';
import 'package:mobile_app/providers/map_preferences_provider.dart'; // Importante
import 'package:provider/provider.dart';

class TarjetaMapaCalor extends StatefulWidget {
  final List<PuntoMapaCalor> puntos;

  const TarjetaMapaCalor({super.key, required this.puntos});

  @override
  State<TarjetaMapaCalor> createState() => _TarjetaMapaCalorState();
}

class _TarjetaMapaCalorState extends State<TarjetaMapaCalor> {
  final MapController _mapController = MapController();
  // ignore: unused_field
  bool _isMapReady = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Obtenemos la ubicación por defecto del usuario desde el Provider
    final mapProvider = context.watch<MapPreferencesProvider>();
    final defaultCenter = mapProvider.activeLocation;

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Distribución Geográfica", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          SizedBox(
            height: 350, // Altura aumentada para mejor interacción
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: defaultCenter, // Usa la ubicación preferida del usuario
                    initialZoom: 15.0, // Zoom más cercano (antes 13)
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    onMapReady: () {
                      setState(() => _isMapReady = true);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.reportapiura.app',
                    ),
                    // Capa de Puntos (Heatmap simulado)
                    CircleLayer(
                      circles: widget.puntos.map((p) => CircleMarker(
                        point: LatLng(p.lat, p.lon),
                        radius: 15, // Radio visualmente notorio
                        color: Colors.red.withOpacity(0.3), // Transparencia para ver densidad
                        borderStrokeWidth: 0,
                      )).toList(),
                    ),
                  ],
                ),
                // Botones de Control (Zoom y Centrar)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'zoom_in_heatmap',
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.add, color: Colors.black87),
                        onPressed: () {
                          final zoom = _mapController.camera.zoom;
                          _mapController.move(_mapController.camera.center, zoom + 1);
                        },
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'zoom_out_heatmap',
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.remove, color: Colors.black87),
                        onPressed: () {
                          final zoom = _mapController.camera.zoom;
                          _mapController.move(_mapController.camera.center, zoom - 1);
                        },
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'center_heatmap',
                        backgroundColor: theme.colorScheme.primary,
                        child: const Icon(Icons.my_location, color: Colors.white),
                        onPressed: () {
                          // Regresa a la ubicación por defecto del usuario
                          _mapController.move(defaultCenter, 15.0);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // DESCRIPCIÓN DETALLADA
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      "Análisis de Zonas Calientes",
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Este mapa inicia centrado en tu ubicación preferida (configurada en 'Preferencias de Mapa'). Las áreas con mayor acumulación de círculos rojos indican una alta densidad de incidentes reportados, sugiriendo la necesidad de intervención prioritaria.",
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}