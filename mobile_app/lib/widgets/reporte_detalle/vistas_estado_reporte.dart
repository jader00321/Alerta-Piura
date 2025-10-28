import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_detallado_model.dart';

/// {@template banner_reporte_oculto}
/// Banner informativo que se muestra dentro de [LayoutDetalleReporte]
/// cuando un reporte tiene estado 'oculto' pero el usuario actual
/// (autor o moderador) tiene permiso para verlo.
/// {@endtemplate}
class BannerReporteOculto extends StatelessWidget {
  /// {@macro banner_reporte_oculto}
  const BannerReporteOculto({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
          color: Colors.amber.shade100, // Fondo amarillo pálido
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.shade700) // Borde ámbar
          ),
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

/// {@template vista_reporte_fusionado}
/// Vista de pantalla completa que reemplaza el contenido normal del detalle
/// cuando un reporte tiene estado 'fusionado'.
///
/// Explica que el reporte es un duplicado y proporciona un botón para navegar
/// al reporte original ([reporte.idReporteOriginal]).
/// {@endtemplate}
class VistaReporteFusionado extends StatelessWidget {
  /// El reporte detallado que está fusionado.
  final ReporteDetallado reporte;
  /// {@macro vista_reporte_fusionado}
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
              // Mensaje explicando la fusión y mostrando el ID del reporte actual.
              'Este reporte (ID: ${reporte.id}) se marcó como duplicado. Puedes ver la información original o seguir al reporte principal.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            // Botón para navegar al reporte original (si existe el ID).
            if (reporte.idReporteOriginal != null)
              ElevatedButton.icon(
                icon: const Icon(Icons.link),
                label: const Text('Ver Reporte Original'),
                onPressed: () {
                  // Reemplaza la pantalla actual con el detalle del reporte original.
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

/// {@template vista_reporte_oculto}
/// Vista de pantalla completa que reemplaza el contenido normal del detalle
/// cuando un reporte tiene estado 'oculto' y el usuario actual *no* tiene
/// permiso para verlo (no es autor ni moderador).
/// {@endtemplate}
class VistaReporteOculto extends StatelessWidget {
  /// {@macro vista_reporte_oculto}
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