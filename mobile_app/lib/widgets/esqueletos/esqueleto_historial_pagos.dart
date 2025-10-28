import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// {@template esqueleto_historial_pagos}
/// Widget de esqueleto (placeholder) con efecto [Shimmer] que imita una lista
/// de [TarjetaHistorialPago].
///
/// Se muestra en [PantallaHistorialPagos] mientras se carga el historial de transacciones.
/// Renderiza una lista de [ListTile] simulados dentro de [Card]s.
/// {@endtemplate}
class EsqueletoHistorialPagos extends StatelessWidget {
  /// {@macro esqueleto_historial_pagos}
  const EsqueletoHistorialPagos({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      // Deshabilita el scroll del ListView para que el RefreshIndicator padre funcione.
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8.0),
        itemCount: 7, // Muestra 7 placeholders para llenar la pantalla.
        itemBuilder: (context, index) {
          /// Simulación de una [TarjetaHistorialPago] individual.
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.white),
              title: Container(
                width: double.infinity,
                height: 16.0,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 8.0),
              ),
              subtitle: Container(
                width: 150,
                height: 12.0,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }
}