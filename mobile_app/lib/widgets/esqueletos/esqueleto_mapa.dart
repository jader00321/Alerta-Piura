import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// {@template esqueleto_mapa}
/// Widget de esqueleto (placeholder) con efecto [Shimmer] que imita la
/// interfaz principal de [MapaView].
///
/// Muestra un fondo estático y placeholders para la barra de búsqueda superior
/// y la barra de navegación inferior, con un indicador de carga central.
/// Se usa mientras el mapa y los datos iniciales se están cargando.
/// {@endtemplate}
class EsqueletoMapa extends StatelessWidget {
  /// {@macro esqueleto_mapa}
  const EsqueletoMapa({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Stack(
        children: [
          /// Fondo del mapa (simulado como un contenedor blanco).
          Container(
            color: Colors.white,
          ),
          /// Simulación de la [TopSearchBar].
          Positioned(
            top: 50, // Aproxima la posición debajo de la barra de estado.
            left: 16,
            right: 16,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          /// Simulación de la [BottomNavigationBar] o [AccionesMapa].
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          /// Indicador de carga central.
          const Center(
            child: CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}