// lib/widgets/verificacion/layout_detalle_verificacion.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_detallado_model.dart';
import 'package:mobile_app/widgets/reporte_detalle/reporte_header.dart'; // Importamos ReporteHeader
import 'package:mobile_app/widgets/verificacion/mapa_verificacion.dart';

class LayoutDetalleVerificacion extends StatelessWidget {
  final ReporteDetallado reporte;
  // Ya no necesitamos isLoadingAction, onEditar, onChat aquí

  const LayoutDetalleVerificacion({
    super.key,
    required this.reporte,
    // Eliminamos los callbacks del constructor
  });

  @override
  Widget build(BuildContext context) {
    // Mantenemos CustomScrollView para la estructura Sliver
    return CustomScrollView(
      slivers: <Widget>[
        // Ya no hay SliverAppBar aquí

        // Cuerpo principal como SliverList
        SliverList(
          delegate: SliverChildListDelegate(
            [
              // Mostramos el header COMPLETO CON IMAGEN aquí
              ReporteHeader(reporte: reporte, showImage: true),

              // Divisor y mapa se mantienen igual
              const Divider(height: 24, indent: 16, endIndent: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ubicación del Reporte',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    // Eliminamos el Hero que envolvía al mapa
                    MapaVerificacion(initialCenter: reporte.location),
                  ],
                ),
              ),
              // Espacio para la barra de acciones inferior
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }
}
