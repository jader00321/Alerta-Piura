import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// {@template esqueleto_lista_notificaciones}
/// Widget de esqueleto (placeholder) con efecto [Shimmer] que imita una lista
/// de [ListTile] simples con [CircleAvatar].
///
/// Se utiliza en [PantallaAlertas] (notificaciones) y
/// [PantallaMetodosPago] mientras se cargan los datos.
/// {@endtemplate}
class EsqueletoListaNotificaciones extends StatelessWidget {
  /// {@macro esqueleto_lista_notificaciones}
  const EsqueletoListaNotificaciones({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(), // Deshabilita scroll
        itemCount: 8, // Muestra 8 placeholders para llenar la pantalla.
        itemBuilder: (context, index) {
          /// Simulación de un [ListTile] de notificación.
          return ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.white), // Simula el icono
            title: Container(
              width: double.infinity,
              height: 16.0,
              color: Colors.white, // Simula el título
            ),
            subtitle: Container(
              margin: const EdgeInsets.only(top: 8.0),
              width: 200,
              height: 12.0,
              color: Colors.white, // Simula el subtítulo
            ),
          );
        },
      ),
    );
  }
}