import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// {@template esqueleto_detalle_boleta}
/// Widget de esqueleto (placeholder) con efecto [Shimmer] que imita la
/// apariencia de la [TarjetaDetalleBoleta].
///
/// Se muestra en [PantallaDetalleBoleta] mientras se cargan los detalles
/// de una transacción específica.
/// {@endtemplate}
class EsqueletoDetalleBoleta extends StatelessWidget {
  /// {@macro esqueleto_detalle_boleta}
  const EsqueletoDetalleBoleta({super.key});

  @override
  Widget build(BuildContext context) {
    // Shimmer proporciona el efecto de brillo animado.
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// Contenedor principal que simula la [Card].
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Simulación de la cabecera (Título y Chip de estado).
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: 150, height: 24, color: Colors.white),
                        Container(
                            width: 80,
                            height: 30,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(width: 200, height: 14, color: Colors.white),
                    const Divider(height: 32),

                    /// Simulación de las filas de detalles.
                    _buildPlaceholderRow(),
                    _buildPlaceholderRow(),
                    _buildPlaceholderRow(),
                    const Divider(height: 32),

                    /// Simulación de los detalles de pago.
                    _buildPlaceholderRow(),
                    _buildPlaceholderRow(),
                    const Divider(height: 32),

                    /// Simulación del Total.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: 100, height: 20, color: Colors.white),
                        Container(width: 80, height: 20, color: Colors.white),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye una fila de placeholder para simular una línea de detalle (título y valor).
  Widget _buildPlaceholderRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(width: 120, height: 16, color: Colors.white),
          Container(width: 150, height: 16, color: Colors.white),
        ],
      ),
    );
  }
}