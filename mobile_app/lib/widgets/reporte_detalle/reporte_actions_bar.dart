import 'package:flutter/material.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ReporteActionsBar extends StatelessWidget {
  final int apoyosCount;
  final int comentariosCount;
  final VoidCallback onSupportPressed;

  const ReporteActionsBar({
    super.key,
    required this.apoyosCount,
    required this.comentariosCount,
    required this.onSupportPressed,
  });

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.read<AuthNotifier>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          TextButton.icon(
            icon: const Icon(Icons.thumb_up_alt_outlined, size: 20),
            label: Text('$apoyosCount Apoyos'),
            onPressed: () {
              if (!authNotifier.isAuthenticated) {
                Navigator.pushNamed(context, '/login');
                return;
              }
              onSupportPressed();
            },
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              const Icon(Icons.comment_outlined, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text('$comentariosCount Comentarios', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
            ],
          ),
        ],
      ),
    );
  }
}