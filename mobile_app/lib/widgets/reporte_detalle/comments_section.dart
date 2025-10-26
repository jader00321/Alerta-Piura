import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/models/comentario_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class CommentsSection extends StatelessWidget {
  final List<Comentario> comentarios;
  final Function(int, String) onEdit;
  final Function(int) onDelete;
  final Function(int) onReportComment;
  final Function(int, String) onReportUser;
  final Function(int) onSupportComment;
  final int? currentUserId;
  final String? currentUserRole;

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
    final authNotifier = context.read<AuthNotifier>();
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Comentarios', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          if (comentarios.isEmpty)
            const Center(
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text('No hay comentarios aún.')))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comentarios.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final c = comentarios[index];
                final bool isOwner = c.idUsuario == authNotifier.userId;
                final bool isLider = authNotifier.isLider;

                String fechaFormateada = 'Fecha inválida';
                try {
                  final dateTime = DateTime.parse(c.fechaCreacion);
                  fechaFormateada =
                      DateFormat('dd MMM yyyy, HH:mm', locale).format(dateTime);
                } catch (e) {
                  debugPrint(
                      "Error parseando fecha del comentario ${c.id}: ${c.fechaCreacion} - $e");
                  fechaFormateada = c.fechaCreacion;
                }

                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            if (authNotifier.isAuthenticated)
                              SizedBox(
                                height: 30,
                                width: 40,
                                child: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, size: 20),
                                  tooltip: 'Más opciones',
                                  onSelected: (value) {
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
                                    if (isOwner)
                                      const PopupMenuItem<String>(
                                          value: 'editar',
                                          child: Text('Editar')),
                                    if (isOwner ||
                                        isLider ||
                                        authNotifier.isAdmin)
                                      const PopupMenuItem<String>(
                                          value: 'eliminar',
                                          child: Text('Eliminar')),
                                    if (!isOwner)
                                      const PopupMenuItem<String>(
                                          value: 'reportar_comentario',
                                          child: Text('Reportar Comentario')),
                                    if ((isLider || authNotifier.isAdmin) &&
                                        !isOwner)
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
                        Text(c.comentario),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 30),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(Icons.thumb_up_alt_outlined,
                                size: 16),
                            label: Text(c.apoyosCount.toString()),
                            onPressed: () {
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
