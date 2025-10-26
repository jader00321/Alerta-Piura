import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class EsqueletoListaNotificaciones extends StatelessWidget {
  const EsqueletoListaNotificaciones({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 8, // Muestra 8 placeholders
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.white),
            title: Container(
              width: double.infinity,
              height: 16.0,
              color: Colors.white,
            ),
            subtitle: Container(
              margin: const EdgeInsets.only(top: 8.0),
              width: 200,
              height: 12.0,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
