import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/models/reporte_model.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_mapa.dart';
// import 'package:fl_heatmap/fl_heatmap.dart'; // TODO: Descomentar si se reactiva el Heatmap

/// {@template capa_mapa_base}
/// Widget fundamental que renderiza el mapa interactivo y los marcadores.
///
/// Utiliza `flutter_map` para la capa base del mapa (TileLayer) y
/// `flutter_map_marker_cluster` para agrupar eficientemente los marcadores
/// de reportes ([Reporte]) cuando hay muchos en un área pequeña.
/// Maneja los estados de carga y error del [reportesFuture].
/// {@endtemplate}
class CapaMapaBase extends StatelessWidget {
  /// Futuro que provee la lista de [Reporte] a mostrar en el mapa.
  final Future<List<Reporte>> reportesFuture;
  /// Futuro opcional para los datos del heatmap. (Actualmente no usado)
  final Future<List<LatLng>>? heatmapFuture;
  /// Controlador del mapa para permitir interacciones programáticas (ej. centrar).
  final MapController mapController;
  /// Coordenada [LatLng] inicial donde se centrará el mapa al cargar.
  final LatLng initialCenter;
  /// Callback que se ejecuta cuando la posición del mapa cambia (ej. por drag).
  final Function(MapEvent) onPositionChanged;
  /// Callback que se ejecuta una vez que el mapa está listo.
  final VoidCallback onMapReady;
  /// Callback que se ejecuta cuando el usuario toca un marcador de reporte.
  final Function(BuildContext, Reporte) onShowReportSummary;
  /// Flag para alternar entre la vista de marcadores y el heatmap.
  final bool isHeatmapVisible;

  /// {@macro capa_mapa_base}
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

  /// Helper para determinar el color del marcador basado en la categoría.
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
        return Colors.purple.shade700; // Color por defecto para otras categorías
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Usa [FutureBuilder] para manejar el estado asíncrono de [reportesFuture].
    return FutureBuilder<List<Reporte>>(
      future: reportesFuture,
      builder: (context, snapshot) {
        // Muestra esqueleto de carga solo en el estado inicial.
        if (snapshot.connectionState == ConnectionState.waiting &&
            (snapshot.data == null || snapshot.data!.isEmpty)) {
          return const EsqueletoMapa();
        }
        // Muestra error si el futuro falla.
        if (snapshot.hasError) {
          return Center(
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error al cargar reportes: ${snapshot.error}')));
        }

        /// Convierte la lista de [Reporte] en una lista de [Marker].
        final markers = (snapshot.data ?? []).map((reporte) {
          return Marker(
            point: reporte.location,
            width: 50,
            height: 50,
            child: GestureDetector(
              onTap: () => onShowReportSummary(context, reporte),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  /// Icono principal del pin, coloreado por categoría.
                  Icon(Icons.location_pin,
                      color: _getCategoryColor(reporte.categoria), size: 45),
                  /// Muestra una estrella si el reporte es prioritario.
                  if (reporte.esPrioritario)
                    Positioned(
                      top: 5,
                      child: Icon(Icons.star,
                          color: Colors.amber,
                          size: 18,
                          shadows: [
                            BoxShadow(
                                color: Colors.black.withAlpha(128),
                                blurRadius: 3)
                          ]),
                    ),
                ],
              ),
            ),
          );
        }).toList();

        /// Construye el widget del mapa.
        return FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: 14.0,
            onMapReady: onMapReady,
            onMapEvent: onPositionChanged, // Llama al callback al mover el mapa
          ),
          children: [
            /// Capa de tiles de OpenStreetMap.
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.mobile_app',
            ),

            /// TODO: Funcionalidad de Heatmap (código comentado).
            /// Descomentar y pasar el [heatmapFuture] para reactivar.
            /*
            if (isHeatmapVisible && heatmapFuture != null)
              FutureBuilder<List<LatLng>>(
                future: heatmapFuture,
                builder: (context, heatmapSnapshot) {
                  if (!heatmapSnapshot.hasData || heatmapSnapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  
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
              ),
            */

            /// Capa de agrupación de marcadores (si no está activo el heatmap).
            if (!isHeatmapVisible)
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 45,
                  size: const Size(40, 40),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(50),
                  markers: markers, // Lista de marcadores creada arriba.
                  /// Constructor para el cluster (círculo con número).
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