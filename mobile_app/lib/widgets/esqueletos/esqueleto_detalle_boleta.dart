import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class EsqueletoDetalleBoleta extends StatelessWidget {
  const EsqueletoDetalleBoleta({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: 150, height: 24, color: Colors.white),
                        Container(width: 80, height: 30, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(width: 200, height: 14, color: Colors.white),
                    const Divider(height: 32),

                    // Details
                    _buildPlaceholderRow(),
                    _buildPlaceholderRow(),
                    _buildPlaceholderRow(),
                    const Divider(height: 32),

                    // Payment details
                    _buildPlaceholderRow(),
                    _buildPlaceholderRow(),
                    const Divider(height: 32),
                    
                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: 100, height: 20, color: Colors.white),
                        Container(width: 80, height: 20, color: Colors.white),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(width: 120, height: 16, color: Colors.white),
          Container(width: 150, height: 16, color: Colors.white),
        ],
      ),
    );
  }
}