import 'package:flutter/material.dart';

/// {@template perfil_action_tile}
/// Widget reutilizable [ListTile] diseñado para mostrar acciones o enlaces
/// de navegación dentro de las tarjetas de sección en [PerfilScreen].
///
/// Muestra un icono a la izquierda, título, subtítulo opcional y un
/// icono de chevron a la derecha. Es tappable a través de [onTap].
/// Puede tener un color personalizado para el icono y el texto.
/// {@endtemplate}
class PerfilActionTile extends StatelessWidget {
  /// El icono a mostrar a la izquierda del título.
  final IconData icon;
  /// El texto principal del tile.
  final String title;
  /// Callback que se ejecuta al tocar el tile.
  final VoidCallback onTap;
  /// Color opcional para el icono, título y chevron. Si es `null`, usa colores del tema.
  final Color? color;
  /// Texto opcional que se muestra debajo del título.
  final String? subtitle;

  /// {@macro perfil_action_tile}
  const PerfilActionTile({
    // Usa super parámetros para la key.
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    // Usa ListTile directamente para integrarse mejor en las Card de PerfilScreen.
    return ListTile(
      leading: Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle!) : null, // Muestra subtítulo si existe.
      trailing: Icon(Icons.chevron_right, color: color ?? Colors.grey.shade400),
      onTap: onTap, // Ejecuta la acción al tocar.
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Bordes redondeados sutiles.
    );
  }
}