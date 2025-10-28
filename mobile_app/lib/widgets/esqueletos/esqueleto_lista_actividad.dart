import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// {@template esqueleto_lista_actividad}
/// Widget de esqueleto (placeholder) genérico con efecto [Shimmer] que imita
/// una lista de tarjetas de actividad, como [TarjetaActividad] o [TarjetaVerificacion].
///
/// Se utiliza en múltiples pantallas que muestran listas, como [MiActividadScreen],
/// [VerificacionScreen] y [PantallaInsignias], mientras se cargan los datos iniciales.
/// {@endtemplate}
class EsqueletoListaActividad extends StatelessWidget {
  /// {@macro esqueleto_lista_actividad}
  const EsqueletoListaActividad({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(), // Deshabilita scroll
        itemCount: 6, // Muestra 6 placeholders.
        itemBuilder: (context, index) {
          /// Simulación de una tarjeta de actividad [ListTile]
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                color: Colors.white, // Simula un avatar o icono
              ),
              title: Container(
                width: double.infinity,
                height: 16.0,
                color: Colors.white, // Simula la línea del título
              ),
              subtitle: Container(
                margin: const EdgeInsets.only(top: 8.0),
                width: 150,
                height: 12.0,
                color: Colors.white, // Simula la línea del subtítulo
              ),
            ),
          );
        },
      ),
    );
  }
}