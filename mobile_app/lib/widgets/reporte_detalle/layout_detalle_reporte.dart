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

/// {@template layout_detalle_reporte}
/// Widget principal que define la estructura y el layout de la pantalla
/// de detalle de un reporte estándar ([ReporteDetalleScreen]).
///
/// Organiza los componentes principales:
/// - [ReporteHeader]: Muestra la información del reporte.
/// - [ReporteActionsBar]: Muestra los botones de apoyo y contador de comentarios.
/// - [MergeNotificationCard]s: Muestra (si existen) los avisos de fusión en un [ExpansionTile].
/// - [CommentsSection]: Muestra la lista de comentarios de usuario.
/// - [CampoComentarioInput] / [PromptLoginComentario]: Muestra el campo para añadir
///   comentarios o un prompt de login, según el estado del reporte y la autenticación.
///
/// También maneja la lógica para mostrar vistas especiales para reportes
/// fusionados ([VistaReporteFusionado]) u ocultos ([VistaReporteOculto], [BannerReporteOculto]).
/// {@endtemplate}
class LayoutDetalleReporte extends StatelessWidget {
  /// Los datos detallados del reporte a mostrar.
  final ReporteDetallado reporte;
  /// El notifier de autenticación para verificar permisos y estado del usuario.
  final AuthNotifier authNotifier;
  /// Callback para el [RefreshIndicator].
  final Future<void> Function() onRefresh;

  /// Callback al presionar el botón de apoyo del reporte.
  final VoidCallback onSupportReport;
  /// Callback al presionar el botón de apoyo de un comentario.
  final Function(int) onSupportComment;
  /// Callback al enviar un nuevo comentario.
  final VoidCallback onPostComment;
  /// Callback al editar un comentario.
  final Function(int, String) onEditComment;
  /// Callback al eliminar un comentario.
  final Function(int) onDeleteComment;
  /// Callback al reportar un comentario.
  final Function(int) onReportComment;
  /// Callback al reportar un usuario.
  final Function(int, String) onReportUser;

  /// Controlador para el campo de texto del nuevo comentario.
  final TextEditingController comentarioController;
  /// Indica si se está enviando un comentario.
  final bool isPostingComment;

  /// {@macro layout_detalle_reporte}
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
    // Si el reporte está fusionado, muestra una vista especial y termina.
    if (reporte.estado == 'fusionado') {
      return ListView(
        padding: const EdgeInsets.symmetric(vertical: 50),
        children: [VistaReporteFusionado(reporte: reporte)],
      );
    }

    final bool isOwner = authNotifier.userId == reporte.idAutor;
    final bool isPrivileged = authNotifier.isLider || authNotifier.isAdmin;

    // Si el reporte está oculto y el usuario no es dueño ni privilegiado,
    // muestra una vista especial y termina.
    if (reporte.estado == 'oculto' && !isOwner && !isPrivileged) {
      return const VistaReporteOculto();
    }

    // Separa los comentarios normales de los avisos de fusión.
    final List<Comentario> mergeNotifications = [];
    final List<Comentario> userComments = [];
    // Patrón para identificar comentarios de fusión (generados por el sistema).
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

    // Estructura principal con Column (para input fijo) y Expanded (para scroll).
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh, // Habilita pull-to-refresh.
            child: ListView(
              children: [
                /// Cabecera con la información del reporte.
                ReporteHeader(reporte: reporte, showImage: true),

                /// Chip opcional indicando reportes vinculados (si > 0).
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
                        backgroundColor: Colors.blue.shade100.withAlpha(204),
                        labelStyle: TextStyle(
                            color: Colors.blue.shade900, fontSize: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),

                /// Banner opcional si el reporte está oculto pero visible para el usuario.
                if (reporte.estado == 'oculto') const BannerReporteOculto(),

                /// Barra de acciones con botones de apoyo y contador de comentarios.
                ReporteActionsBar(
                  apoyosCount: reporte.apoyosCount,
                  comentariosCount: userComments.length, // Usa comentarios filtrados
                  onSupportPressed: onSupportReport,
                ),

                /// Sección expandible para mostrar el historial de fusiones.
                if (mergeNotifications.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: ExpansionTile(
                      // Clave para mantener estado de expansión entre refrescos.
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
                      initiallyExpanded: false, // Colapsado por defecto.
                      children: mergeNotifications
                          .map((c) => MergeNotificationCard(comentario: c))
                          .toList(),
                    ),
                  ),

                /// Sección principal de comentarios de usuario.
                CommentsSection(
                  comentarios: userComments, // Pasa comentarios filtrados.
                  onEdit: onEditComment,
                  onDelete: onDeleteComment,
                  onReportComment: onReportComment,
                  onReportUser: onReportUser,
                  onSupportComment: onSupportComment,
                  currentUserId: authNotifier.userId,
                  currentUserRole: authNotifier.userRole,
                ),
                const SizedBox(height: 20), // Espacio al final.
              ],
            ),
          ),
        ),

        /// Campo de entrada de comentario o prompt de login (condicional).
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
          // No muestra campo de comentario si el reporte está pendiente, rechazado, etc.
          const SizedBox.shrink(),
      ],
    );
  }
}