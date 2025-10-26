// lib/widgets/verificacion/tarjeta_moderacion_reporte.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_moderacion_model.dart';

/// Tarjeta para mostrar un reporte de moderación (usuario o comentario)
/// realizado por el líder en su historial "Mis Reportes".
class TarjetaModeracionReporte extends StatelessWidget {
  final ReporteModeracion reporteModeracion;
  final VoidCallback onTap; // Navegar al contexto
  final Function(int moderacionReporteId, TipoReporteModeracion tipo)? onQuitar;
  final bool isDeleting;

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
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 12.0, 8.0, 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila Superior: Tipo de Reporte y Estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        esComentario
                            ? Icons.chat_bubble_outline
                            : Icons.person_outline,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        esComentario
                            ? 'Reporte de Comentario'
                            : 'Reporte de Usuario',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Chip(
                    avatar: Icon(statusIcon, size: 14, color: statusColor),
                    label: Text(reporteModeracion.estado,
                        style: TextStyle(fontSize: 10, color: statusColor)),
                    backgroundColor: statusColor.withOpacity(0.1),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ],
              ),
              const Divider(height: 16),

              // Contenido/Usuario Reportado
              Text(
                esComentario ? 'Contenido:' : 'Usuario Reportado:',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
              Text(
                esComentario
                    ? '"${reporteModeracion.contenido}"'
                    : reporteModeracion.contenido,
                style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle:
                        esComentario ? FontStyle.italic : FontStyle.normal),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // --- CORRECCIÓN: Mostrar Código/ID ---
              if (esComentario)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    // Muestra el código si existe, si no, el ID del reporte
                    'En reporte: ${reporteModeracion.codigoReporte ?? '#${reporteModeracion.idReporte ?? 'N/A'}'}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey[600], fontSize: 11),
                  ),
                )
              else if (reporteModeracion.idUsuarioReportado != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    // Muestra el ID del usuario
                    'Usuario ID: #${reporteModeracion.idUsuarioReportado}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey[600], fontSize: 11),
                  ),
                ),
              // --- FIN CORRECCIÓN ---
              const SizedBox(height: 8),

              // Motivo
              Text(
                'Motivo:',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
              Text(
                reporteModeracion.motivo,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Fecha y Botón Quitar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      'Fecha: ${reporteModeracion.fecha}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                  ),
                  if (estaPendiente && onQuitar != null)
                    SizedBox(
                      height: 30,
                      child: TextButton.icon(
                        icon: isDeleting
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.delete_forever_outlined,
                                size: 16),
                        label: const Text('Quitar',
                            style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red.shade400,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: isDeleting
                            ? null
                            : () => onQuitar!(
                                reporteModeracion.id, reporteModeracion.tipo),
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
