import 'package:flutter/material.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// {@template reporte_actions_bar}
/// Barra de acciones que se muestra debajo de la cabecera en la pantalla
/// de detalle de reporte ([ReporteDetalleScreen]).
///
/// Muestra el contador de apoyos con un botón para dar/quitar apoyo,
/// y el contador de comentarios.
/// Si el usuario no está autenticado, el botón de apoyo redirige a la pantalla de login.
/// {@endtemplate}
class ReporteActionsBar extends StatelessWidget {
  /// El número actual de apoyos que tiene el reporte.
  final int apoyosCount;
  /// El número actual de comentarios que tiene el reporte.
  final int comentariosCount;
  /// Callback que se ejecuta al presionar el botón de apoyo.
  final VoidCallback onSupportPressed;

  /// {@macro reporte_actions_bar}
  const ReporteActionsBar({
    super.key,
    required this.apoyosCount,
    required this.comentariosCount,
    required this.onSupportPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Necesitamos el AuthNotifier para saber si redirigir a login.
    final authNotifier = context.read<AuthNotifier>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          /// Botón y contador de apoyos.
          TextButton.icon(
            icon: const Icon(Icons.thumb_up_alt_outlined, size: 20),
            label: Text('$apoyosCount Apoyos'),
            onPressed: () {
              // Si no está autenticado, ir a login.
              if (!authNotifier.isAuthenticated) {
                Navigator.pushNamed(context, '/login');
                return;
              }
              // Si está autenticado, ejecutar la acción de apoyo.
              onSupportPressed();
            },
          ),
          const SizedBox(width: 16),
          /// Contador de comentarios (solo visual).
          Row(
            children: [
              const Icon(Icons.comment_outlined, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text('$comentariosCount Comentarios',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color)),
            ],
          ),
        ],
      ),
    );
  }
}