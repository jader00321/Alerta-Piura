import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// {@template esqueleto_lista_reportes}
/// Widget de esqueleto (placeholder) con efecto [Shimmer] que imita una
/// lista de tarjetas de reporte simples.
///
/// Se utiliza en [PantallaCercaDeTi] y [PantallaBuscarReporteOriginal]
/// mientras se cargan los datos de los reportes.
/// Muestra 5 placeholders que simulan una tarjeta con título, categoría y subtítulo.
/// {@endtemplate}
class EsqueletoListaReportes extends StatelessWidget {
  /// {@macro esqueleto_lista_reportes}
  const EsqueletoListaReportes({super.key});

  @override
  Widget build(BuildContext context) {
    // El widget [Shimmer] proporciona el efecto de brillo animado.
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      // Deshabilita el scroll del ListView para permitir que el
      // RefreshIndicator de la pantalla padre funcione correctamente.
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5, // Muestra 5 placeholders para llenar la vista inicial.
        itemBuilder: (context, index) {
          /// Simulación de una tarjeta de reporte individual.
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Placeholder para el chip de categoría o estado.
                  Container(
                    width: 120,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  /// Placeholder para el título del reporte.
                  Container(
                    width: double.infinity,
                    height: 24,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  /// Placeholder para el subtítulo (autor/fecha).
                  Container(
                    width: 200,
                    height: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}