// lib/widgets/perfil/perfil_action_tile.dart
import 'package:flutter/material.dart';

class PerfilActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;
  final String? subtitle; // <-- NUEVO: Subtítulo opcional

  const PerfilActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
    this.subtitle, // <-- Añadido
  });

  @override
  Widget build(BuildContext context) {
    // --- CORRECCIÓN: Quitar Card y usar ListTile directamente ---
    return ListTile(
      leading:
          Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
      title: Text(title,
          style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      subtitle:
          subtitle != null ? Text(subtitle!) : null, // <-- Mostrar subtítulo
      trailing: Icon(Icons.chevron_right, color: color ?? Colors.grey.shade400),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
    // --- FIN CORRECCIÓN ---
  }
}
