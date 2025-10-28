import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_detallado_model.dart';
import 'package:mobile_app/widgets/reporte_detalle/reporte_header.dart';
import 'package:mobile_app/widgets/verificacion/mapa_verificacion.dart';

/// {@template cuerpo_detalle_verificacion}
/// Widget que define el contenido principal (scrollable) dentro de la pantalla
/// [VerificacionDetalleScreen]. Muestra los detalles del reporte y el mapa.
///
/// Utiliza [ReporteHeader] (configurado sin imagen) y [MapaVerificacion].
/// *Nota: Su funcionalidad puede solaparse con [LayoutDetalleVerificacion]. Considerar refactorización.*
/// {@endtemplate}
@Deprecated(
    'Considerar usar LayoutDetalleVerificacion directamente o refactorizar. '
    'Funcionalidad solapada.')
class CuerpoDetalleVerificacion extends StatelessWidget {
  /// Los datos detallados del reporte a mostrar.
  final ReporteDetallado reporte;

  /// {@macro cuerpo_detalle_verificacion}
  const CuerpoDetalleVerificacion({super.key, required this.reporte});

  @override
  Widget build(BuildContext context) {
    // Usa SliverList para integrarse con CustomScrollView si es necesario.
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            // Muestra el header sin la imagen principal.
            child: ReporteHeader(reporte: reporte, showImage: false),
          ),
          const Divider(height: 24, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ubicación del Reporte',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                // Muestra el mapa no interactivo centrado en la ubicación del reporte.
                // Se envuelve en Material para evitar problemas visuales si se usa Hero.
                Material(
                  type: MaterialType.transparency,
                  child: MapaVerificacion(initialCenter: reporte.location),
                ),
              ],
            ),
          ),
          // Espacio reservado en la parte inferior para la barra de acciones [AccionesModeracion].
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}