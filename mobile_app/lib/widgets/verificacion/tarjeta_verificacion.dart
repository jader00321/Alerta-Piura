// lib/widgets/verificacion/tarjeta_verificacion.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_pendiente_model.dart';

class TarjetaVerificacion extends StatelessWidget {
  final ReportePendiente reporte;
  final VoidCallback onTap;

  const TarjetaVerificacion({
    super.key,
    required this.reporte,
    required this.onTap,
  });

  // --- Helpers Visuales ---
  Color _getUrgencyColor(String? urgency) {
    switch (urgency?.toLowerCase()) {
      case 'alta': return Colors.red.shade600;
      case 'media': return Colors.orange.shade700;
      case 'baja': return Colors.green.shade600;
      default: return Colors.grey.shade600;
    }
  }

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
    final bool hasPhoto = reporte.fotoUrl != null && reporte.fotoUrl!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Sección Imagen (Condicional) ---
            if (hasPhoto)
              SizedBox(
                height: 100,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      reporte.fotoUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) => progress == null
                          ? child
                          : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.grey.shade300, child: const Center(child: Icon(Icons.broken_image, size: 30, color: Colors.grey))),
                    ),
                    // Degradado
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                          stops: const [0.0, 0.6],
                        ),
                      ),
                    ),
                  ],
                ),
              ), // Fin SizedBox Imagen

            // --- Sección Detalles Debajo ---
            Padding(
              padding: EdgeInsets.fromLTRB(12.0, hasPhoto ? 12.0 : 16.0 , 12.0, 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // --- NUEVO: Fila 1 - Chips de Estado/Prioridad ---
                  if (isPriority || hasPendingSupport) ...[ // Solo mostrar la fila si hay al menos un chip
                    Row(
                      children: [
                        // Chip de Prioridad (si es premium)
                        if (isPriority)
                          Chip(
                            avatar: Icon(Icons.star_rounded, size: 14, color: Colors.amber.shade800),
                            label: const Text('Premium'),
                            backgroundColor: Colors.amber.shade100.withOpacity(0.9),
                            labelStyle: TextStyle(fontSize: 11, color: Colors.amber.shade800, fontWeight: FontWeight.bold),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        if (isPriority && hasPendingSupport) const SizedBox(width: 8), // Espacio entre chips
                        // Chip de Apoyos Pendientes (si existen)
                        if (hasPendingSupport)
                          Chip(
                            avatar: Icon(Icons.local_fire_department_rounded, size: 14, color: Colors.red.shade800),
                            label: Text('+${reporte.apoyosPendientes}'),
                            backgroundColor: Colors.red.shade100.withOpacity(0.9),
                            labelStyle: TextStyle(fontSize: 11, color: Colors.red.shade900, fontWeight: FontWeight.bold),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                             materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8), // Espacio después de la primera fila de chips
                  ],
                  // --- FIN NUEVO ---

                   // Fila 2 - Categoría y Urgencia
                  Row(
                    children: [
                       Flexible(
                         child: Chip(
                           label: Text(
                               reporte.categoria,
                               style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                               overflow: TextOverflow.ellipsis,
                           ),
                           visualDensity: VisualDensity.compact,
                           padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                           backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.7),
                           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                         ),
                       ),
                       const SizedBox(width: 8),
                       if (reporte.urgencia != null)
                         Chip(
                           avatar: Icon(_getUrgencyIcon(reporte.urgencia), size: 14, color: _getUrgencyColor(reporte.urgencia)),
                           label: Text(reporte.urgencia!, style: TextStyle(fontSize: 11, color: _getUrgencyColor(reporte.urgencia), fontWeight: FontWeight.bold)),
                           visualDensity: VisualDensity.compact,
                           padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                           backgroundColor: _getUrgencyColor(reporte.urgencia).withOpacity(0.15),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                         ),
                       // Los chips de Premium y Apoyos se movieron a la fila anterior
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Título
                  Text(
                    reporte.titulo,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Autor y Fecha
                   Text(
                     'Por ${reporte.autor} • ${reporte.fecha}',
                     style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.8)),
                     overflow: TextOverflow.ellipsis,
                   ),

                ],
              ),
            ), // Fin Padding Detalles
          ],
        ),
      ),
    );
  }
}