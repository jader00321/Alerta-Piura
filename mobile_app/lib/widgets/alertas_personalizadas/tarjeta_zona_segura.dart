import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TarjetaZonaSegura extends StatelessWidget {
  final String nombreZona;
  final LatLng centro;
  final double radio;
  final VoidCallback onDelete;

  const TarjetaZonaSegura({
    super.key,
    required this.nombreZona,
    required this.centro,
    required this.radio,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 150,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: centro,
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.mobile_app',
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: centro,
                      radius: radio,
                      useRadiusInMeter: true,
                      color: theme.colorScheme.primary
                          .withAlpha(51), // CORREGIDO: withOpacity -> withAlpha
                      borderColor: theme.colorScheme.primary,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombreZona,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Radio: ${(radio / 1000).toStringAsFixed(1)} km',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
                  onPressed: onDelete,
                  tooltip: 'Eliminar Zona',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
