import 'package:flutter/material.dart';
import 'package:mobile_app/models/comentario_model.dart';

class MergeNotificationCard extends StatelessWidget {
  final Comentario comentario;
  const MergeNotificationCard({super.key, required this.comentario});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      color: Colors.blueGrey.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.blueGrey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: Colors.blueGrey.shade700, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comentario.comentario,
                    style: TextStyle(
                        color: Colors.blueGrey.shade800, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Por ${comentario.autor} • ${comentario.fechaCreacion}',
                    style: TextStyle(
                        color: Colors.blueGrey.shade600, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
