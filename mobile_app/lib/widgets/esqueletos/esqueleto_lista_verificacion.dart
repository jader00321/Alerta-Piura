/*import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class EsqueletoListaVerificacion extends StatelessWidget {
  const EsqueletoListaVerificacion({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: 7, // Muestra 7 placeholders
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
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
}*/