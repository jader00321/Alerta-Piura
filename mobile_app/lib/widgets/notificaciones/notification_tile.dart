import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/models/notificacion_model.dart';

/// {@template notification_tile}
/// Widget que representa una fila en la lista de notificaciones.
///
/// Actualizado con soporte nativo para **Modo Oscuro**:
/// - Ajusta dinámicamente los colores de fondo y texto según el brillo del tema.
/// - Mejora la visibilidad de los estados "Leído" vs "No leído".
/// {@endtemplate}
class NotificationTile extends StatelessWidget {
  final Notificacion notificacion;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Function(DismissDirection)? onDismissed;

  const NotificationTile({
    super.key,
    required this.notificacion,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isUnread = !notificacion.leido;
    final bool isDark = theme.brightness == Brightness.dark;

    // Formato de fecha
    final now = DateTime.now();
    final date = notificacion.fechaEnvio;
    final bool isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final String timeString = isToday 
        ? DateFormat('HH:mm').format(date) 
        : DateFormat('dd MMM').format(date);

    // --- LÓGICA DE COLORES ADAPTATIVA ---
    Color tileColor;
    Color titleColor;
    Color bodyColor;
    Color iconBgColor;

    if (isSelected) {
      // Estado: Seleccionado (Azuloso en ambos modos)
      tileColor = theme.colorScheme.primaryContainer.withOpacity(isDark ? 0.5 : 0.4);
      titleColor = isDark ? Colors.white : Colors.black;
      bodyColor = isDark ? Colors.grey.shade300 : Colors.grey.shade800;
      iconBgColor = Colors.transparent;
    } else if (isUnread) {
      // Estado: No Leído (Resaltado)
      // En oscuro usamos una opacidad mayor (0.25) para que se note sobre el negro
      tileColor = theme.colorScheme.primary.withOpacity(isDark ? 0.25 : 0.08);
      titleColor = isDark ? Colors.white : Colors.black; // Texto blanco puro en oscuro
      bodyColor = isDark ? Colors.grey.shade200 : Colors.grey.shade900;
      iconBgColor = theme.colorScheme.primaryContainer;
    } else {
      // Estado: Leído (Plano)
      tileColor = theme.scaffoldBackgroundColor; // Se funde con el fondo
      titleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700; // Texto apagado
      bodyColor = isDark ? Colors.grey.shade600 : Colors.grey.shade600;
      iconBgColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    }

    return Dismissible(
      key: Key('notif_${notificacion.id}'),
      direction: isSelectionMode ? DismissDirection.none : DismissDirection.horizontal,
      onDismissed: onDismissed,
      background: Container(
        color: Colors.green.shade700,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Row(children: [Icon(Icons.archive, color: Colors.white), SizedBox(width: 8), Text("Archivar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
      ),
      secondaryBackground: Container(
        color: Colors.red.shade700,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text("Eliminar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), SizedBox(width: 8), Icon(Icons.delete, color: Colors.white)]),
      ),
      child: InkWell(
        onTap: isSelectionMode ? onLongPress : onTap,
        onLongPress: onLongPress,
        child: Container(
          color: tileColor,
          child: Row(
            children: [
              // Indicador lateral de "No leído"
              if (isUnread && !isSelectionMode)
                Container(width: 4, height: 72, color: theme.colorScheme.primary)
              else
                const SizedBox(width: 4),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- ICONO / AVATAR ---
                      if (isSelectionMode)
                        Padding(
                          padding: const EdgeInsets.only(right: 16, top: 8),
                          child: Icon(
                            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isSelected ? theme.colorScheme.primary : Colors.grey,
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: CircleAvatar(
                            backgroundColor: iconBgColor,
                            child: Icon(
                              _getCategoryIcon(notificacion.categoria),
                              color: isUnread 
                                  ? theme.colorScheme.primary 
                                  : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
                              size: 20,
                            ),
                          ),
                        ),

                      // --- CONTENIDO TEXTUAL ---
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    notificacion.titulo,
                                    style: TextStyle(
                                      fontWeight: isUnread ? FontWeight.w800 : FontWeight.w500,
                                      fontSize: 15,
                                      color: titleColor, // Color adaptativo
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Hora
                                Row(
                                  children: [
                                    if (isUnread) 
                                      Icon(Icons.mark_email_unread, size: 14, color: theme.colorScheme.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      timeString,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                                        color: isUnread 
                                            ? theme.colorScheme.primary 
                                            : (isDark ? Colors.grey.shade500 : Colors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notificacion.cuerpo,
                              style: TextStyle(
                                color: bodyColor, // Color adaptativo
                                fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'seguridad': return Icons.security;
      case 'sistema': return Icons.info_outline;
      case 'chat': return Icons.chat;
      case 'comentario': return Icons.comment; 
      default: return Icons.notifications_none;
    }
  }
}