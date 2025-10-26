import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class EsqueletoMapa extends StatelessWidget {
  const EsqueletoMapa({super.key});

  @override
  Widget build(BuildContext context) {
    // Shimmer proporciona el efecto de brillo animado
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Stack(
        children: [
          // Fondo del mapa como un contenedor gris
          Container(
            color: Colors.white,
          ),
          // Simulación de la barra de búsqueda
          Positioned(
            top: 50,
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
          // Simulación de la barra de navegación inferior
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
          // Indicador de carga en el centro
          const Center(
            child: CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}
