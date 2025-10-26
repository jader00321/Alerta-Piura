import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/models/reporte_model.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_mapa.dart';
//import 'package:fl_heatmap/fl_heatmap.dart'; // IMPORT CORRECTO

class CapaMapaBase extends StatelessWidget {
  final Future<List<Reporte>> reportesFuture;
  final Future<List<LatLng>>? heatmapFuture;
  final MapController mapController;
  final LatLng initialCenter;
  final Function(MapEvent)
      onPositionChanged; // CORREGIDO: MapPosition -> MapEvent
  final VoidCallback onMapReady;
  final Function(BuildContext, Reporte) onShowReportSummary;
  final bool isHeatmapVisible;

  const CapaMapaBase({
    super.key,
    required this.reportesFuture,
    this.heatmapFuture,
    required this.mapController,
    required this.initialCenter,
    required this.onPositionChanged,
    required this.onMapReady,
    required this.onShowReportSummary,
    required this.isHeatmapVisible,
  });

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'delito':
        return Colors.red.shade700;
      case 'falla de alumbrado':
        return Colors.orange.shade700;
      case 'bache':
        return Colors.brown.shade700;
      case 'basura':
        return Colors.grey.shade700;
      default:
        return Colors.purple.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Reporte>>(
      future: reportesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            (snapshot.data == null || snapshot.data!.isEmpty)) {
          return const EsqueletoMapa();
        }
        if (snapshot.hasError) {
          return Center(
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error al cargar reportes: ${snapshot.error}')));
        }

        final markers = (snapshot.data ?? [])
            .map((reporte) => Marker(
                  point: reporte.location,
                  width: 50,
                  height: 50,
                  child: GestureDetector(
                    onTap: () => onShowReportSummary(context, reporte),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.location_pin,
                            color: _getCategoryColor(reporte.categoria),
                            size: 45),
                        if (reporte.esPrioritario)
                          Positioned(
                            top: 5,
                            child: Icon(Icons.star,
                                color: Colors.amber,
                                size: 18,
                                shadows: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 3)
                                ]),
                          ),
                      ],
                    ),
                  ),
                ))
            .toList();

        return FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: 14.0,
            onMapReady: onMapReady,
            onMapEvent:
                onPositionChanged, // CORREGIDO: onPositionChanged -> onMapEvent
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.mobile_app',
            ),

            /*if (isHeatmapVisible)
              FutureBuilder<List<LatLng>>(
                future: heatmapFuture,
                builder: (context, heatmapSnapshot) {
                  if (!heatmapSnapshot.hasData || heatmapSnapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  
                  // SINTAXIS CORREGIDA
                  final heatmapData = heatmapSnapshot.data!
                      .map((latlng) => WeightedLocation(location: latlng, weight: 1.0))
                      .toList();

                  return Heatmap(
                    heatmapData: heatmapData,
                    config: HeatmapConfig(
                      radius: 30,
                      colorPalette: HeatmapColor.defaults,
                    ),
                  );
                },
              ),*/

            if (!isHeatmapVisible)
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 45,
                  size: const Size(40, 40),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(50),
                  markers: markers,
                  builder: (context, markers) => Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).colorScheme.primary),
                    child: Center(
                        child: Text(markers.length.toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
