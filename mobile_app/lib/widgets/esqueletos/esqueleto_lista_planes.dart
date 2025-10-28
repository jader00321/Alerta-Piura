import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// {@template esqueleto_lista_planes}
/// Widget de esqueleto (placeholder) con efecto [Shimmer] que imita la
/// apariencia de las tarjetas de [TarjetaPlan].
///
/// Se muestra en [PantallaPlanesSuscripcion] mientras se cargan los
/// planes de suscripción disponibles.
/// {@endtemplate}
class EsqueletoListaPlanes extends StatelessWidget {
  /// {@macro esqueleto_lista_planes}
  const EsqueletoListaPlanes({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(), // Deshabilita scroll
        padding: const EdgeInsets.all(16.0),
        itemCount: 2, // Muestra 2 placeholders de tarjetas de plan.
        itemBuilder: (context, index) {
          /// Simulación de una [TarjetaPlan] completa.
          return Card(
            elevation: 4.0,
            margin: const EdgeInsets.only(bottom: 24.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Simulación de Título y Precio.
                  Container(width: 200, height: 28, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: 100, height: 24, color: Colors.white),
                  const Divider(height: 32),
                  /// Simulación de la lista de características.
                  ...List.generate(
                      4,
                      (i) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              children: [
                                Container(
                                    width: 20, height: 20, color: Colors.white),
                                const SizedBox(width: 12),
                                Container(
                                    width: 220,
                                    height: 16,
                                    color: Colors.white),
                              ],
                            ),
                          )),
                  const SizedBox(height: 16),
                  /// Simulación del botón "Seleccionar Plan".
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
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