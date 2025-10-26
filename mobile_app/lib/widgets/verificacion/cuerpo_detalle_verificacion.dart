// lib/widgets/verificacion/cuerpo_detalle_verificacion.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_detallado_model.dart';
import 'package:mobile_app/widgets/reporte_detalle/reporte_header.dart';
import 'package:mobile_app/widgets/verificacion/mapa_verificacion.dart';

class CuerpoDetalleVerificacion extends StatelessWidget {
  final ReporteDetallado reporte;

  const CuerpoDetalleVerificacion({super.key, required this.reporte});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            // --- CORRECCIÓN: Indicar al header que NO muestre la imagen ---
            child: ReporteHeader(reporte: reporte, showImage: false),
            // --- FIN CORRECCIÓN ---
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
                // --- CORRECCIÓN: Eliminar el widget Hero ---
                // El Hero causaba el error rojo en el mapa.
                Material(
                  type: MaterialType.transparency, // Evitar conflictos visuales
                  child: MapaVerificacion(initialCenter: reporte.location),
                ),
                // --- FIN CORRECCIÓN ---
              ],
            ),
          ),
          // Espacio para la barra de acciones inferior
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
