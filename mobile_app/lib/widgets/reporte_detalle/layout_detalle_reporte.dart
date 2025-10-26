// lib/widgets/reporte_detalle/layout_detalle_reporte.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_detallado_model.dart';
import 'package:mobile_app/models/comentario_model.dart'; // Necesario para MergeNotificationCard
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/widgets/reporte_detalle/reporte_header.dart';
import 'package:mobile_app/widgets/reporte_detalle/reporte_actions_bar.dart';
import 'package:mobile_app/widgets/reporte_detalle/comments_section.dart';
import 'package:mobile_app/widgets/reporte_detalle/vistas_estado_reporte.dart';
import 'package:mobile_app/widgets/reporte_detalle/campo_comentario.dart';
import 'package:mobile_app/widgets/reporte_detalle/merge_notification_card.dart';
// Quita import de provider si no se usa directamente aquí

class LayoutDetalleReporte extends StatelessWidget {
  final ReporteDetallado reporte;
  final AuthNotifier authNotifier;
  final Future<void> Function() onRefresh;

  // Callbacks de acciones
  final VoidCallback onSupportReport;
  final Function(int) onSupportComment;
  final VoidCallback onPostComment;
  final Function(int, String) onEditComment;
  final Function(int) onDeleteComment;
  final Function(int) onReportComment;
  final Function(int, String) onReportUser;

  final TextEditingController comentarioController;
  final bool isPostingComment;

  const LayoutDetalleReporte({
    super.key,
    required this.reporte,
    required this.authNotifier,
    required this.onRefresh,
    required this.onSupportReport,
    required this.onSupportComment,
    required this.onPostComment,
    required this.onEditComment,
    required this.onDeleteComment,
    required this.onReportComment,
    required this.onReportUser,
    required this.comentarioController,
    required this.isPostingComment,
  });

  @override
  Widget build(BuildContext context) {
    // Manejo de estados especiales (fusionado, oculto inaccesible)
    if (reporte.estado == 'fusionado') {
      // Usar ListView ayuda a centrar verticalmente si el contenido es corto
      return ListView(
        padding: const EdgeInsets.symmetric(
            vertical: 50), // Añade padding si es necesario
        children: [VistaReporteFusionado(reporte: reporte)],
      );
    }

    final bool isOwner = authNotifier.userId == reporte.idAutor;
    final bool isPrivileged = authNotifier.isLider || authNotifier.isAdmin;

    if (reporte.estado == 'oculto' && !isOwner && !isPrivileged) {
      return const VistaReporteOculto();
    }

    // --- Filtrado de Comentarios ---
    final List<Comentario> mergeNotifications = [];
    final List<Comentario> userComments = [];
    final mergePattern =
        RegExp(r'^Reporte #.* fue fusionado con este', caseSensitive: false);
    for (var comentario in reporte.comentarios) {
      bool isLikelyMergeNotification =
          mergePattern.hasMatch(comentario.comentario);
      if (isLikelyMergeNotification) {
        mergeNotifications.add(comentario);
      } else {
        userComments.add(comentario);
      }
    }
    // --- Fin Filtrado ---

    // --- Vista Normal ---
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView(
              // Usamos ListView normal aquí
              children: [
                ReporteHeader(reporte: reporte, showImage: true),

                // --- Chip de Vinculados (Corregido) ---
                if (reporte.reportesVinculadosCount > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    child: Align(
                      // Alinearlo a la izquierda
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        // Icono y color azul marino
                        avatar: Icon(Icons.merge_type,
                            color: Colors.blue.shade900, size: 16),
                        label: Text(
                            '${reporte.reportesVinculadosCount} reporte(s) vinculado(s)'),
                        // Color de fondo azul claro y texto azul marino
                        backgroundColor: Colors.blue.shade100.withOpacity(0.8),
                        labelStyle: TextStyle(
                            color: Colors.blue.shade900, fontSize: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2), // Ajustar padding
                        visualDensity:
                            VisualDensity.compact, // hacerlo más compacto
                      ),
                    ),
                  ),
                // --- Fin Chip Corregido ---

                // Banner si está oculto pero visible para el usuario actual
                if (reporte.estado == 'oculto') const BannerReporteOculto(),

                // Barra de acciones (Apoyos, Comentarios)
                ReporteActionsBar(
                  apoyosCount: reporte.apoyosCount,
                  comentariosCount: userComments
                      .length, // Usar longitud de comentarios filtrados
                  onSupportPressed: onSupportReport,
                  // TODO: Pasar estado 'supported' si tienes esa lógica
                ),

                // --- NUEVO: Sección de Avisos de Fusión ---
                if (mergeNotifications.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0), // Ajustar padding
                    child: ExpansionTile(
                      // Clave para mantener estado si se reconstruye mucho
                      key: PageStorageKey('fusionHistory_${reporte.id}'),
                      title: Text(
                        'Historial de Fusión (${mergeNotifications.length})',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal: 8.0), // Padding interno
                      childrenPadding: const EdgeInsets.only(
                          bottom: 8.0), // Padding para el contenido
                      initiallyExpanded: false, // Empieza colapsado
                      children: mergeNotifications
                          .map((c) => MergeNotificationCard(comentario: c))
                          .toList(),
                    ),
                  ),
                // --- FIN NUEVO ---

                // Sección de comentarios (ahora con comentarios filtrados)
                CommentsSection(
                  comentarios: userComments, // Pasar la lista filtrada
                  onEdit: onEditComment,
                  onDelete: onDeleteComment,
                  onReportComment: onReportComment,
                  onReportUser: onReportUser,
                  onSupportComment: onSupportComment,
                  // Pasar currentUserId para lógica de botones
                  currentUserId: authNotifier.userId,
                  currentUserRole: authNotifier
                      .userRole, // Pasar rol para permisos de borrado
                ),
                const SizedBox(height: 20), // Espacio al final del scroll
              ],
            ),
          ),
        ),

        // --- Input de Comentario Condicional ---
        // Lógica sin cambios, se muestra según estado y auth
        if (authNotifier.isAuthenticated &&
            (reporte.estado == 'verificado' || reporte.estado == 'oculto'))
          CampoComentarioInput(
            controller: comentarioController,
            isPosting: isPostingComment,
            onSend: onPostComment,
          )
        else if (!authNotifier.isAuthenticated &&
            (reporte.estado == 'verificado' || reporte.estado == 'oculto'))
          const PromptLoginComentario()
        else
          const SizedBox
              .shrink(), // No mostrar input si está pendiente/rechazado/fusionado
      ],
    );
  }
}
