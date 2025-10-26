// lib/widgets/reporte_detalle/vistas_estado_reporte.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_detallado_model.dart';

/// Muestra un banner para reportes que están 'ocultos' pero son visibles para el usuario.
class BannerReporteOculto extends StatelessWidget {
  const BannerReporteOculto({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
          color: Colors.amber.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.shade700)),
      child: Row(
        children: [
          Icon(Icons.visibility_off_outlined, color: Colors.amber.shade900),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Este reporte está oculto. Solo tú y los moderadores pueden verlo.',
              style: TextStyle(
                  color: Colors.amber.shade900, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

/// Muestra una pantalla completa para un reporte que fue fusionado.
class VistaReporteFusionado extends StatelessWidget {
  final ReporteDetallado reporte;
  const VistaReporteFusionado({super.key, required this.reporte});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.merge_type_outlined,
                size: 80, color: Colors.purple.shade300),
            const SizedBox(height: 24),
            Text(
              'Reporte Fusionado',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Este reporte (ID: ${reporte.id}) se marcó como duplicado. Puedes ver la información original o seguir al reporte principal.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            if (reporte.idReporteOriginal != null)
              ElevatedButton.icon(
                icon: const Icon(Icons.link),
                label: const Text('Ver Reporte Original'),
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    '/reporte_detalle',
                    arguments: reporte.idReporteOriginal,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Muestra una pantalla completa para un reporte 'oculto' que el usuario no puede ver.
class VistaReporteOculto extends StatelessWidget {
  const VistaReporteOculto({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.visibility_off_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 24),
            Text(
              'Reporte No Disponible',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Este reporte ha sido ocultado por un moderador y ya no es visible públicamente.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
