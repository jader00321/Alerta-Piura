import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// {@template esqueleto_reporte_detalle}
/// Widget de esqueleto (placeholder) con efecto [Shimmer] que imita la
/// apariencia de la pantalla de detalle de reporte ([ReporteDetalleScreen] o
/// [VerificacionDetalleScreen]).
///
/// Simula la imagen, los chips de categoría, el título, la barra de acciones
/// y una lista de comentarios.
/// {@endtemplate}
class EsqueletoReporteDetalle extends StatelessWidget {
  /// {@macro esqueleto_reporte_detalle}
  const EsqueletoReporteDetalle({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(), // Deshabilita scroll
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Placeholder para la imagen del reporte.
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.white,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Placeholder para los chips (Categoría, Urgencia).
                  Row(
                    children: [
                      Container(
                          width: 80,
                          height: 30,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20))),
                      const SizedBox(width: 8),
                      Container(
                          width: 120,
                          height: 30,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  /// Placeholder para el título.
                  Container(
                      width: double.infinity, height: 28, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: 200, height: 16, color: Colors.white),
                  const SizedBox(height: 16),

                  /// Placeholder para la [ReporteActionsBar].
                  Row(
                    children: [
                      Container(width: 100, height: 20, color: Colors.white),
                      const SizedBox(width: 16),
                      Container(width: 120, height: 20, color: Colors.white),
                    ],
                  ),
                  const Divider(height: 32),

                  /// Placeholder para la sección de comentarios.
                  Container(width: 150, height: 24, color: Colors.white),
                  const SizedBox(height: 16),
                  _buildCommentPlaceholder(),
                  const SizedBox(height: 16),
                  _buildCommentPlaceholder(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye un placeholder que simula un [ListTile] de comentario.
  Widget _buildCommentPlaceholder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(radius: 20, backgroundColor: Colors.white),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 100, height: 14, color: Colors.white),
                const SizedBox(height: 4),
                Container(width: 80, height: 12, color: Colors.white),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(width: double.infinity, height: 14, color: Colors.white),
        const SizedBox(height: 4),
        Container(width: 250, height: 14, color: Colors.white),
      ],
    );
  }
}