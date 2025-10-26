import 'package:flutter/material.dart';
import 'package:mobile_app/models/comentario_model.dart';

class MergeNotificationCard extends StatelessWidget {
  final Comentario comentario;
  const MergeNotificationCard({Key? key, required this.comentario})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      color: Colors.blueGrey.shade50, // Fondo distinto
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.blueGrey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Alinear icono arriba
          children: [
            Icon(Icons.info_outline, color: Colors.blueGrey.shade700, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                // Para alinear texto y fecha
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comentario.comentario, // El texto del aviso
                    style: TextStyle(
                        color: Colors.blueGrey.shade800, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // Mostrar autor y fecha del aviso
                    'Por ${comentario.autor} • ${comentario.fechaCreacion}', // Asume que fechaCreacion está formateada
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
