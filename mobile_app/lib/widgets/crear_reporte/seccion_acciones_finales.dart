import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class SeccionAccionesFinales extends StatelessWidget {
  final bool isAnonimo;
  final Function(bool?) onAnonimoChanged;
  final VoidCallback onGetCurrentLocation;
  final LatLng? currentLocation;
  final bool isLoading;
  final VoidCallback onSubmitReport;

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
            CheckboxListTile(
              title: const Text('Publicar como anónimo'),
              value: isAnonimo,
              onChanged: onAnonimoChanged,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.my_location),
              label: const Text('Obtener Ubicación Actual'),
              onPressed: onGetCurrentLocation,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            if (currentLocation != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Ubicación obtenida: ${currentLocation!.latitude.toStringAsFixed(4)}, ${currentLocation!.longitude.toStringAsFixed(4)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : onSubmitReport,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                    )
                  : const Text('Enviar Reporte'),
            ),
          ],
        ),
      ),
    );
  }
}