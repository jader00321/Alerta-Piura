import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_pendiente_model.dart';

/// {@template tarjeta_verificacion}
/// Tarjeta para mostrar un reporte pendiente de verificación en la lista
/// del líder ([ListaReportesVerificacion]).
///
/// Muestra información clave para la priorización: título, categoría, fecha,
/// autor, y chips para 'Prioritario' y 'Con Apoyos'. Es tappable para
/// navegar al detalle [VerificacionDetalleScreen].
/// {@endtemplate}
class TarjetaVerificacion extends StatelessWidget {
  /// Los datos del reporte pendiente a mostrar.
  final ReportePendiente reporte;
  /// Callback que se ejecuta al tocar la tarjeta.
  final VoidCallback onTap;

  /// {@macro tarjeta_verificacion}
  const TarjetaVerificacion({
    super.key,
    required this.reporte,
    required this.onTap,
  });

  /// Determina el color basado en la urgencia.
  Color _getUrgencyColor(String? urgency) {
    switch (urgency?.toLowerCase()) {
      case 'alta': return Colors.red.shade600;
      case 'media': return Colors.orange.shade700;
      case 'baja': return Colors.green.shade600;
      default: return Colors.grey.shade600;
    }
  }

  /// Determina el icono basado en la urgencia.
  IconData _getUrgencyIcon(String? urgency) {
    switch (urgency?.toLowerCase()) {
      case 'alta': return Icons.priority_high_rounded;
      case 'media': return Icons.warning_amber_rounded;
      case 'baja': return Icons.low_priority_rounded;
      default: return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPendingSupport = reporte.apoyosPendientes > 0;
    final isPriority = reporte.esPrioritario;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Muestra la imagen del reporte si existe.
            if (reporte.fotoUrl != null && reporte.fotoUrl!.isNotEmpty)
              Image.network(
                reporte.fotoUrl!,
                width: 100,
                height: 120, // Altura fija para consistencia
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const SizedBox(
                        width: 100,
                        height: 120,
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 120,
                    color: Colors.grey.shade200,
                    child: const Center(
                        child: Icon(Icons.broken_image,
                            size: 30, color: Colors.grey))),
              ),
            /// Columna con los detalles del reporte.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Fila superior con chips de Prioridad y Apoyos.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Wrap(
                            spacing: 4.0,
                            runSpacing: 4.0,
                            children: [
                              if (isPriority)
                                Chip(
                                  avatar: const Icon(Icons.star, size: 14, color: Colors.white),
                                  label: const Text('Prioritario'),
                                  labelStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                  backgroundColor: Colors.amber.shade700,
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              if (hasPendingSupport)
                                Chip(
                                  avatar: Icon(Icons.people_alt, size: 14, color: Colors.blue.shade900),
                                  label: Text('+${reporte.apoyosPendientes} Apoyo${reporte.apoyosPendientes > 1 ? 's' : ''}'),
                                  labelStyle: TextStyle(fontSize: 10, color: Colors.blue.shade900, fontWeight: FontWeight.bold),
                                  backgroundColor: Colors.blue.shade100,
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                            ],
                          ),
                        ),
                        // Espacio para evitar que los chips choquen con el borde
                        const SizedBox(width: 8),
                      ],
                    ),
                    const SizedBox(height: 6),

                    /// Fila con chips de Categoría y Urgencia.
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 4.0,
                      children: [
                        Chip(
                          label: Text(reporte.categoria, style: const TextStyle(fontSize: 11)),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          backgroundColor: theme.colorScheme.secondaryContainer.withAlpha(179),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        if (reporte.urgencia != null)
                          Chip(
                            avatar: Icon(_getUrgencyIcon(reporte.urgencia), size: 14, color: _getUrgencyColor(reporte.urgencia)),
                            label: Text(reporte.urgencia!, style: TextStyle(fontSize: 11, color: _getUrgencyColor(reporte.urgencia), fontWeight: FontWeight.bold)),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                            backgroundColor: _getUrgencyColor(reporte.urgencia).withAlpha(38),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    /// Título del reporte.
                    Text(
                      reporte.titulo,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    /// Autor y Fecha.
                    Text(
                      'Por ${reporte.autor} • ${reporte.fecha}',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withAlpha(204)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}