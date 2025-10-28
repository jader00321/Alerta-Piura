import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// {@template mapa_verificacion}
/// Widget que muestra un mapa no interactivo centrado en una ubicación específica.
///
/// Utilizado en las pantallas de detalle ([VerificacionDetalleScreen],
/// [PantallaDetallePendienteVista]) para mostrar dónde ocurrió el reporte.
/// Incluye botones flotantes para hacer zoom y recentrar.
/// {@endtemplate}
class MapaVerificacion extends StatefulWidget {
  /// El punto geográfico [LatLng] donde se centrará el mapa.
  final LatLng initialCenter;

  /// {@macro mapa_verificacion}
  const MapaVerificacion({super.key, required this.initialCenter});

  @override
  State<MapaVerificacion> createState() => _MapaVerificacionState();
}

/// Estado para [MapaVerificacion].
///
/// Maneja el [MapController] para las acciones de zoom y recentrado.
class _MapaVerificacionState extends State<MapaVerificacion> {
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define una altura fija para el mapa.
    return SizedBox(
      height: 250,
      child: Card(
        clipBehavior: Clip.antiAlias, // Recorta el mapa a los bordes del Card
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            /// El widget principal [FlutterMap].
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.initialCenter,
                initialZoom: 16.0, // Zoom inicial relativamente cercano
                // Deshabilitar interacción del usuario con el mapa:
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none, // Ninguna interacción habilitada
                ),
              ),
              children: [
                /// Capa base del mapa (OpenStreetMap).
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.mobile_app',
                ),
                /// Capa que muestra un único marcador en el centro inicial.
                MarkerLayer(
                  markers: [
                    Marker(
                      point: widget.initialCenter,
                      width: 80, // Tamaño del marcador
                      height: 80,
                      child: const Icon(Icons.location_pin,
                          color: Colors.red, size: 40), // Icono del marcador
                    )
                  ],
                ),
              ],
            ),
            /// Botones flotantes superpuestos para controlar el mapa.
            Positioned(
              bottom: 10,
              right: 10,
              child: Column(
                children: [
                  /// Botón Zoom In.
                  FloatingActionButton.small(
                    heroTag: 'zoomInBtn_verif', // Tag único para Hero animation
                    onPressed: () => _mapController.move(
                        _mapController.camera.center, _mapController.camera.zoom + 1),
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 8),
                  /// Botón Zoom Out.
                  FloatingActionButton.small(
                    heroTag: 'zoomOutBtn_verif',
                    onPressed: () => _mapController.move(
                        _mapController.camera.center, _mapController.camera.zoom - 1),
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(height: 8),
                  /// Botón para recentrar en la ubicación inicial del reporte.
                  FloatingActionButton.small(
                    heroTag: 'centerBtn_verif',
                    onPressed: () => _mapController.move(widget.initialCenter, 16.0), // Vuelve al zoom 16
                    child: const Icon(Icons.my_location),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}