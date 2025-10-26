import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class EsqueletoListaActividad extends StatelessWidget {
  const EsqueletoListaActividad({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 6, // Muestra 6 placeholders
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                color: Colors.white,
              ),
              title: Container(
                width: double.infinity,
                height: 16.0,
                color: Colors.white,
              ),
              subtitle: Container(
                margin: const EdgeInsets.only(top: 8.0),
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
