import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// {@template tarjeta_zona_segura}
/// Widget de tarjeta que muestra una Zona Segura definida por el usuario.
///
/// Contiene un mini-mapa ([FlutterMap]) que muestra la ubicación ([centro])
/// y el [radio] de la zona como un [CircleLayer].
/// También muestra el [nombreZona] y un botón para eliminar ([onDelete]).
/// Utilizado en [PantallaAlertasPersonalizadas].
/// {@endtemplate}
class TarjetaZonaSegura extends StatelessWidget {
  /// El nombre personalizado de la zona (ej. "Casa", "Oficina").
  final String nombreZona;
  /// Las coordenadas [LatLng] del centro de la zona.
  final LatLng centro;
  /// El radio en metros de la zona segura.
  final double radio;
  /// Callback que se ejecuta al presionar el botón de eliminar.
  final VoidCallback onDelete;

  /// {@macro tarjeta_zona_segura}
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
      clipBehavior: Clip.antiAlias, // Recorta el mapa a los bordes del Card
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Mini-mapa que muestra la zona.
          SizedBox(
            height: 150,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: centro,
                initialZoom: 14, // Zoom predeterminado para ver la zona
                // Deshabilita la interacción del usuario con el mini-mapa
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.mobile_app',
                ),
                /// Capa que dibuja el círculo de la zona segura.
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: centro,
                      radius: radio, // El radio en metros
                      useRadiusInMeter: true,
                      color: theme.colorScheme.primary.withAlpha(51), // Relleno
                      borderColor: theme.colorScheme.primary, // Borde
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              ],
            ),
          ),
          /// Sección de información y botón de eliminar.
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
                        'Radio: ${(radio / 1000).toStringAsFixed(1)} km', // Muestra el radio en km
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                /// Botón para eliminar la zona.
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
                  onPressed: onDelete, // Llama al callback del padre
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