import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaVerificacion extends StatefulWidget {
  final LatLng initialCenter;

  const MapaVerificacion({super.key, required this.initialCenter});

  @override
  State<MapaVerificacion> createState() => _MapaVerificacionState();
}

class _MapaVerificacionState extends State<MapaVerificacion> {
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.initialCenter,
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
                      point: widget.initialCenter,
                      width: 80,
                      height: 80,
                      child: const Icon(Icons.location_pin,
                          color: Colors.red, size: 40),
                    )
                  ],
                ),
              ],
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: 'zoomInBtn_verif',
                    onPressed: () => _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1),
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'zoomOutBtn_verif',
                    onPressed: () => _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1),
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'centerBtn_verif',
                    onPressed: () =>
                        _mapController.move(widget.initialCenter, 16.0),
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
