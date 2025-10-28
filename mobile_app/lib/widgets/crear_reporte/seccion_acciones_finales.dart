import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// {@template seccion_acciones_finales}
/// Widget reutilizable que muestra las acciones finales en el formulario de
/// creación/edición de reportes ([CreateReportScreen]).
///
/// Incluye:
/// - Un [CheckboxListTile] para marcar el reporte como anónimo.
/// - Un [OutlinedButton] para obtener la ubicación GPS actual del usuario.
/// - Un [Text] que muestra las coordenadas obtenidas (si [currentLocation] no es nulo).
/// - Un [ElevatedButton] principal para enviar el formulario, que muestra
///   un [CircularProgressIndicator] si [isLoading] es `true`.
/// {@endtemplate}
class SeccionAccionesFinales extends StatelessWidget {
  /// El estado actual del checkbox "Publicar como anónimo".
  final bool isAnonimo;
  /// Callback que se ejecuta cuando el valor del checkbox cambia.
  final Function(bool?) onAnonimoChanged;
  /// Callback que se ejecuta al presionar el botón "Obtener Ubicación".
  final VoidCallback onGetCurrentLocation;
  /// La ubicación [LatLng] actual obtenida (o `null` si no se ha obtenido).
  final LatLng? currentLocation;
  /// Indica si el formulario se está enviando o si se está obteniendo la ubicación.
  final bool isLoading;
  /// Callback que se ejecuta al presionar el botón "Enviar Reporte".
  final VoidCallback onSubmitReport;

  /// {@macro seccion_acciones_finales}
  const SeccionAccionesFinales({
    super.key,
    required this.isAnonimo,
    required this.onAnonimoChanged,
    required this.onGetCurrentLocation,
    this.currentLocation,
    required this.isLoading,
    required this.onSubmitReport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// Checkbox para reporte anónimo.
            CheckboxListTile(
              title: const Text('Publicar como anónimo'),
              value: isAnonimo,
              onChanged: onAnonimoChanged,
              controlAffinity: ListTileControlAffinity.leading, // Checkbox a la izquierda.
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            /// Botón para obtener ubicación.
            OutlinedButton.icon(
              icon: const Icon(Icons.my_location),
              label: const Text('Obtener Ubicación Actual'),
              onPressed: onGetCurrentLocation, // Llama al callback del padre.
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            /// Muestra las coordenadas si se obtuvieron.
            if (currentLocation != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Ubicación obtenida: ${currentLocation!.latitude.toStringAsFixed(4)}, ${currentLocation!.longitude.toStringAsFixed(4)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.green.shade700, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 24),
            /// Botón principal para enviar el reporte.
            ElevatedButton(
              // Deshabilitado si [isLoading] es true.
              onPressed: isLoading ? null : onSubmitReport,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  // Muestra un spinner si está cargando.
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 3, color: Colors.white),
                    )
                  : const Text('Enviar Reporte'),
            ),
          ],
        ),
      ),
    );
  }
}