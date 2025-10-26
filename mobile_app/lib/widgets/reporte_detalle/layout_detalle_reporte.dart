import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_detallado_model.dart';
import 'package:mobile_app/models/comentario_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/widgets/reporte_detalle/reporte_header.dart';
import 'package:mobile_app/widgets/reporte_detalle/reporte_actions_bar.dart';
import 'package:mobile_app/widgets/reporte_detalle/comments_section.dart';
import 'package:mobile_app/widgets/reporte_detalle/vistas_estado_reporte.dart';
import 'package:mobile_app/widgets/reporte_detalle/campo_comentario.dart';
import 'package:mobile_app/widgets/reporte_detalle/merge_notification_card.dart';

class LayoutDetalleReporte extends StatelessWidget {
  final ReporteDetallado reporte;
  final AuthNotifier authNotifier;
  final Future<void> Function() onRefresh;

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
    if (reporte.estado == 'fusionado') {
      return ListView(
        padding: const EdgeInsets.symmetric(vertical: 50),
        children: [VistaReporteFusionado(reporte: reporte)],
      );
    }

    final bool isOwner = authNotifier.userId == reporte.idAutor;
    final bool isPrivileged = authNotifier.isLider || authNotifier.isAdmin;

    if (reporte.estado == 'oculto' && !isOwner && !isPrivileged) {
      return const VistaReporteOculto();
    }

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

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView(
              children: [
                ReporteHeader(reporte: reporte, showImage: true),
                if (reporte.reportesVinculadosCount > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        avatar: Icon(Icons.merge_type,
                            color: Colors.blue.shade900, size: 16),
                        label: Text(
                            '${reporte.reportesVinculadosCount} reporte(s) vinculado(s)'),
                        backgroundColor:
                            Colors.blue.shade100.withAlpha(204), // CORREGIDO
                        labelStyle: TextStyle(
                            color: Colors.blue.shade900, fontSize: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                if (reporte.estado == 'oculto') const BannerReporteOculto(),
                ReporteActionsBar(
                  apoyosCount: reporte.apoyosCount,
                  comentariosCount: userComments.length,
                  onSupportPressed: onSupportReport,
                ),
                if (mergeNotifications.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: ExpansionTile(
                      key: PageStorageKey('fusionHistory_${reporte.id}'),
                      title: Text(
                        'Historial de Fusión (${mergeNotifications.length})',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      tilePadding: const EdgeInsets.symmetric(horizontal: 8.0),
                      childrenPadding: const EdgeInsets.only(bottom: 8.0),
                      initiallyExpanded: false,
                      children: mergeNotifications
                          .map((c) => MergeNotificationCard(comentario: c))
                          .toList(),
                    ),
                  ),
                CommentsSection(
                  comentarios: userComments,
                  onEdit: onEditComment,
                  onDelete: onDeleteComment,
                  onReportComment: onReportComment,
                  onReportUser: onReportUser,
                  onSupportComment: onSupportComment,
                  currentUserId: authNotifier.userId,
                  currentUserRole: authNotifier.userRole,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
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
          const SizedBox.shrink(),
      ],
    );
  }
}
