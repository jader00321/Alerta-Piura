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
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          TextButton.icon(
            icon: const Icon(Icons.thumb_up_alt_outlined),
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
          TextButton.icon(
            icon: const Icon(Icons.comment_outlined),
            label: Text('$comentariosCount Comentarios'),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}