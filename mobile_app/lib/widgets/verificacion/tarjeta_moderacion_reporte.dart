import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_moderacion_model.dart';

/// {@template tarjeta_moderacion_reporte}
/// Tarjeta para mostrar un reporte de moderación (sobre un comentario o usuario)
/// creado por el líder actual, dentro de la vista [MisReportesModeracionView].
///
/// Muestra el motivo del reporte, el contenido afectado y permite al líder
/// "Quitar" (cancelar) su propio reporte si aún está en estado 'pendiente'.
/// {@endtemplate}
class TarjetaModeracionReporte extends StatelessWidget {
  /// Los datos del reporte de moderación a mostrar.
  final ReporteModeracion reporteModeracion;
  /// Callback que se ejecuta al tocar la tarjeta (para navegar al contexto).
  final VoidCallback onTap;
  /// Callback que se ejecuta al presionar "Quitar". Se pasa el ID y el tipo. Es opcional.
  final Function(int moderacionReporteId, TipoReporteModeracion tipo)? onQuitar;
  /// Indica si se está procesando la acción de quitar.
  final bool isDeleting;

  /// {@macro tarjeta_moderacion_reporte}
  const TarjetaModeracionReporte({
    super.key,
    required this.reporteModeracion,
    required this.onTap,
    this.onQuitar,
    this.isDeleting = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool esComentario =
        reporteModeracion.tipo == TipoReporteModeracion.comentario;
    final bool estaPendiente = reporteModeracion.estado == 'pendiente';

    // Determina color e icono según el estado del reporte de moderación.
    Color statusColor;
    IconData statusIcon;
    switch (reporteModeracion.estado) {
      case 'pendiente':
        statusColor = Colors.orange.shade800;
        statusIcon = Icons.hourglass_empty_outlined;
        break;
      default: // resuelto, etc.
        statusColor = Colors.green.shade800;
        statusIcon = Icons.check_circle_outline;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Fila superior: Tipo (Comentario/Usuario) y Estado.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    avatar: Icon(esComentario
                        ? Icons.comment_outlined
                        : Icons.person_outline),
                    label: Text(esComentario ? 'Comentario' : 'Usuario'),
                    visualDensity: VisualDensity.compact,
                  ),
                  Chip(
                    avatar: Icon(statusIcon, size: 14, color: statusColor),
                    label: Text(reporteModeracion.estado),
                    labelStyle: TextStyle(
                        fontSize: 10,
                        color: statusColor,
                        fontWeight: FontWeight.bold),
                    backgroundColor: statusColor.withAlpha(26), // Transparente
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              /// Motivo del reporte.
              Text(
                'Motivo: ${reporteModeracion.motivo}',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              /// Contenido afectado (extracto del comentario o alias del usuario).
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  reporteModeracion.contenido,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontStyle: FontStyle.italic),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              /// Fila inferior: Fecha y botón opcional "Quitar".
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      'Fecha: ${reporteModeracion.fecha}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                  ),
                  // Muestra el botón "Quitar" solo si está pendiente y hay callback.
                  if (estaPendiente && onQuitar != null)
                    SizedBox(
                      height: 30, // Altura fija para el botón
                      child: TextButton.icon(
                        icon: isDeleting
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.delete_forever_outlined, size: 16),
                        label: const Text('Quitar', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red.shade400,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: isDeleting
                            ? null
                            : () =>
                                onQuitar!(reporteModeracion.id, reporteModeracion.tipo),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}