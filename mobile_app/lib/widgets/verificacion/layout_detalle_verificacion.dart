import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_detallado_model.dart';
import 'package:mobile_app/widgets/reporte_detalle/reporte_header.dart';
import 'package:mobile_app/widgets/verificacion/mapa_verificacion.dart';

/// {@template layout_detalle_verificacion}
/// Define la estructura principal del contenido scrollable dentro de la
/// pantalla de detalle de verificación ([VerificacionDetalleScreen]).
///
/// Utiliza un [CustomScrollView] con un [SliverList] que contiene:
/// - [ReporteHeader]: Muestra la información principal del reporte (con imagen).
/// - [MapaVerificacion]: Muestra un mapa no interactivo de la ubicación.
/// {@endtemplate}
class LayoutDetalleVerificacion extends StatelessWidget {
  /// Los datos detallados del reporte a mostrar.
  final ReporteDetallado reporte;

  /// {@macro layout_detalle_verificacion}
  const LayoutDetalleVerificacion({
    super.key,
    required this.reporte,
  });

  @override
  Widget build(BuildContext context) {
    // CustomScrollView permite combinar elementos scrollables y no scrollables (Slivers).
    return CustomScrollView(
      slivers: <Widget>[
        // SliverList contiene los elementos principales del cuerpo.
        SliverList(
          delegate: SliverChildListDelegate(
            [
              /// Muestra la cabecera completa del reporte, incluyendo la imagen.
              ReporteHeader(reporte: reporte, showImage: true),

              const Divider(height: 24, indent: 16, endIndent: 16),

              /// Sección que muestra el mapa de ubicación.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ubicación del Reporte',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    /// Mapa no interactivo centrado en la ubicación del reporte.
                    MapaVerificacion(initialCenter: reporte.location),
                  ],
                ),
              ),
              /// Espacio al final para asegurar que el contenido no quede oculto
              /// por la barra de acciones inferior ([AccionesModeracion]).
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }
}