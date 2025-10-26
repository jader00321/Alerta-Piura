import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class EsqueletoReporteDetalle extends StatelessWidget {
  const EsqueletoReporteDetalle({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  Container(
                      width: double.infinity, height: 28, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: 200, height: 14, color: Colors.white),
                  const Divider(height: 32),
                  Row(
                    children: [
                      Container(width: 100, height: 20, color: Colors.white),
                      const SizedBox(width: 16),
                      Container(width: 120, height: 20, color: Colors.white),
                    ],
                  ),
                  const Divider(height: 32),
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
