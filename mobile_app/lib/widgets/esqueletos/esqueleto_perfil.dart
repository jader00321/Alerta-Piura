import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class EsqueletoPerfil extends StatelessWidget {
  const EsqueletoPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    // Shimmer proporciona el efecto de brillo animado que mejora la percepción de carga.
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Esqueleto para el PerfilHeaderCard
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const CircleAvatar(radius: 50, backgroundColor: Colors.white),
                  const SizedBox(height: 16),
                  Container(width: 150, height: 24, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: 200, height: 14, color: Colors.white),
                  const SizedBox(height: 24),
                  Container(width: 120, height: 20, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Esqueleto para los PerfilActionTile
          _buildPlaceholderTile(),
          _buildPlaceholderTile(),
          _buildPlaceholderTile(),
          _buildPlaceholderTile(),
          
          const Divider(height: 48),

          // Esqueleto para la InsigniasSection
          Container(width: 200, height: 24, color: Colors.white),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            children: List.generate(3, (index) => Chip(
              label: SizedBox(width: 80, height: 16, child: Container(color: Colors.white)),
              backgroundColor: Colors.white,
            )),
          )
        ],
      ),
    );
  }

  // Widget auxiliar para crear los placeholders de los botones de acción
  Widget _buildPlaceholderTile() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(radius: 20, backgroundColor: Colors.white),
        title: Container(
          width: 180,
          height: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}