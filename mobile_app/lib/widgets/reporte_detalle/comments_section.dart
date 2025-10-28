import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/models/comentario_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// {@template comments_section}
/// Widget que renderiza la sección de comentarios de un reporte detallado.
///
/// Muestra una lista de [Comentario] en tarjetas individuales.
/// Cada tarjeta incluye información del autor, fecha, texto del comentario,
/// contador de apoyos y un menú contextual ([PopupMenuButton]) con acciones
/// (Editar, Eliminar, Reportar Comentario, Reportar Usuario) que se muestran
/// condicionalmente según los permisos del usuario actual ([currentUserId], [currentUserRole]).
/// {@endtemplate}
class CommentsSection extends StatelessWidget {
  /// Lista de comentarios a mostrar.
  final List<Comentario> comentarios;
  /// Callback al seleccionar "Editar" en el menú (recibe ID y texto actual).
  final Function(int, String) onEdit;
  /// Callback al seleccionar "Eliminar" en el menú (recibe ID).
  final Function(int) onDelete;
  /// Callback al seleccionar "Reportar Comentario" en el menú (recibe ID).
  final Function(int) onReportComment;
  /// Callback al seleccionar "Reportar Usuario" en el menú (recibe ID y alias).
  final Function(int, String) onReportUser;
  /// Callback al presionar el botón de apoyo de un comentario (recibe ID).
  final Function(int) onSupportComment;
  /// ID del usuario actualmente logueado (para lógica de permisos).
  final int? currentUserId;
  /// Rol del usuario actualmente logueado (para lógica de permisos).
  final String? currentUserRole;

  /// {@macro comments_section}
  const CommentsSection({
    super.key,
    required this.comentarios,
    required this.onEdit,
    required this.onDelete,
    required this.onReportComment,
    required this.onReportUser,
    required this.onSupportComment,
    this.currentUserId,
    this.currentUserRole,
  });

  @override
  Widget build(BuildContext context) {
    // Usar read para obtener el AuthNotifier una sola vez.
    final authNotifier = context.read<AuthNotifier>();
    final theme = Theme.of(context);
    // Locale para formatear fechas.
    final locale = Localizations.localeOf(context).toString();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Comentarios', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          // Mensaje si no hay comentarios.
          if (comentarios.isEmpty)
            const Center(
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text('No hay comentarios aún.')))
          else
            // Lista de comentarios.
            ListView.separated(
              shrinkWrap: true, // Para usar dentro de otro ListView.
              physics: const NeverScrollableScrollPhysics(), // Deshabilita scroll propio.
              itemCount: comentarios.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final c = comentarios[index];
                final bool isOwner = c.idUsuario == authNotifier.userId;
                final bool isLider = authNotifier.isLider;

                // Formatea la fecha del comentario.
                String fechaFormateada = 'Fecha inválida';
                try {
                  // Asume que fechaCreacion es un String ISO 8601.
                  final dateTime = DateTime.parse(c.fechaCreacion);
                  fechaFormateada =
                      DateFormat('dd MMM yyyy, HH:mm', locale).format(dateTime);
                } catch (e) {
                  debugPrint(
                      "Error parseando fecha del comentario ${c.id}: ${c.fechaCreacion} - $e");
                  // Muestra el string original si falla el parseo.
                  fechaFormateada = c.fechaCreacion;
                }

                // Construye la tarjeta para cada comentario.
                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Fila con avatar, nombre, fecha y menú de opciones.
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                                radius: 16,
                                child: Text(c.autor.isNotEmpty
                                    ? c.autor[0].toUpperCase()
                                    : '?')),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.autor,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                    fechaFormateada,
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            /// Menú de opciones contextual.
                            if (authNotifier.isAuthenticated)
                              SizedBox(
                                height: 30, // Limita altura para mejor tap area
                                width: 40,
                                child: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, size: 20),
                                  tooltip: 'Más opciones',
                                  onSelected: (value) {
                                    // Ejecuta la acción correspondiente al callback.
                                    if (value == 'editar') {
                                      onEdit(c.id, c.comentario);
                                    }
                                    if (value == 'eliminar') {
                                      onDelete(c.id);
                                    }
                                    if (value == 'reportar_comentario') {
                                      onReportComment(c.id);
                                    }
                                    if (value == 'reportar_usuario') {
                                      onReportUser(c.idUsuario, c.autor);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry<String>>[
                                    // Opciones condicionales según permisos.
                                    if (isOwner)
                                      const PopupMenuItem<String>(
                                          value: 'editar', child: Text('Editar')),
                                    if (isOwner || isLider || authNotifier.isAdmin)
                                      const PopupMenuItem<String>(
                                          value: 'eliminar', child: Text('Eliminar')),
                                    if (!isOwner)
                                      const PopupMenuItem<String>(
                                          value: 'reportar_comentario',
                                          child: Text('Reportar Comentario')),
                                    if ((isLider || authNotifier.isAdmin) && !isOwner)
                                      const PopupMenuItem<String>(
                                          value: 'reportar_usuario',
                                          child: Text('Reportar Usuario')),
                                  ],
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        /// Texto del comentario.
                        Text(c.comentario),
                        /// Fila con botón de apoyo y contador.
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 30),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(Icons.thumb_up_alt_outlined, size: 16),
                            label: Text(c.apoyosCount.toString()),
                            onPressed: () {
                              // Redirige a login si no está autenticado.
                              if (!authNotifier.isAuthenticated) {
                                Navigator.pushNamed(context, '/login');
                                return;
                              }
                              onSupportComment(c.id);
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}