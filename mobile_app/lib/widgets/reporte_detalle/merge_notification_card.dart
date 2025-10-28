import 'package:flutter/material.dart';
import 'package:mobile_app/models/comentario_model.dart';

/// {@template merge_notification_card}
/// Tarjeta especializada para mostrar los comentarios generados por el sistema
/// cuando ocurre una fusión de reportes.
///
/// Utiliza un estilo visual distinto para diferenciarse de los comentarios de usuario.
/// Se muestra dentro de un [ExpansionTile] en [LayoutDetalleReporte].
/// {@endtemplate}
class MergeNotificationCard extends StatelessWidget {
  /// El objeto [Comentario] que contiene el mensaje de notificación de fusión.
  final Comentario comentario;

  /// {@macro merge_notification_card}
  const MergeNotificationCard({super.key, required this.comentario});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      color: Colors.blueGrey.shade50, // Fondo diferenciado.
      elevation: 0, // Sin sombra.
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.blueGrey.shade200) // Borde sutil.
          ),
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
                  /// Texto del mensaje de fusión.
                  Text(
                    comentario.comentario,
                    style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  /// Autor (sistema/líder) y fecha del mensaje.
                  Text(
                    'Por ${comentario.autor} • ${comentario.fechaCreacion}',
                    style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 11),
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