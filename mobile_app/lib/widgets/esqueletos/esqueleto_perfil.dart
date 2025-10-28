import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// {@template esqueleto_perfil}
/// Widget de esqueleto (placeholder) con efecto [Shimmer] que imita la
/// apariencia de la pantalla de [PerfilScreen].
///
/// Simula la [PerfilHeaderCard], la [InsigniaEstatusWidget] (como un tile),
/// varias [PerfilActionTile] y la sección de insignias.
/// {@endtemplate}
class EsqueletoPerfil extends StatelessWidget {
  /// {@macro esqueleto_perfil}
  const EsqueletoPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(), // Deshabilita scroll
        padding: const EdgeInsets.all(16.0),
        children: [
          /// Esqueleto para [PerfilHeaderCard].
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

          /// Esqueleto para [InsigniaEstatusWidget] y [PerfilActionTile]s.
          _buildPlaceholderTile(),
          _buildPlaceholderTile(),
          _buildPlaceholderTile(),
          _buildPlaceholderTile(),

          const Divider(height: 48),

          /// Esqueleto para la sección de insignias.
          Container(width: 200, height: 24, color: Colors.white),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            children: List.generate(
                3,
                (index) => Chip(
                      label: SizedBox(
                          width: 80, height: 16, child: Container(color: Colors.white)),
                      backgroundColor: Colors.white,
                    )),
          )
        ],
      ),
    );
  }

  /// Construye un placeholder que simula un [PerfilActionTile] o [InsigniaEstatusWidget].
  Widget _buildPlaceholderTile() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(radius: 20, backgroundColor: Colors.white),
        title: Container(width: 200, height: 16, color: Colors.white),
      ),
    );
  }
}