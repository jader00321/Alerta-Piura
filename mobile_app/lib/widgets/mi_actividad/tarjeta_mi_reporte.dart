// lib/widgets/mi_actividad/tarjeta_mi_reporte.dart (NUEVO ARCHIVO)
import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_resumen_model.dart';

class TarjetaMiReporte extends StatelessWidget {
  final ReporteResumen reporte;
  final VoidCallback? onCancelar; // Callback para el botón cancelar
  final VoidCallback? onTap;       // Callback para tap en la tarjeta

  const TarjetaMiReporte({
    super.key,
    required this.reporte,
    this.onCancelar,
    this.onTap,
  });

  // Helper para el chip de estado (similar a otros widgets)
  Widget _buildStatusChip(BuildContext context) {
    String label = reporte.estado.toUpperCase();
    Color bgColor = Colors.grey.shade200;
    Color fgColor = Colors.grey.shade800;
    IconData? icon;

    switch (reporte.estado) {
      case 'pendiente_verificacion':
        label = 'Pendiente';
        bgColor = Colors.orange.shade100;
        fgColor = Colors.orange.shade900;
        icon = Icons.hourglass_empty_outlined;
        break;
      case 'verificado':
        label = 'Verificado';
        bgColor = Colors.green.shade100;
        fgColor = Colors.green.shade900;
        icon = Icons.check_circle_outline;
        break;
      case 'rechazado':
        label = 'Rechazado';
        bgColor = Colors.red.shade100;
        fgColor = Colors.red.shade900;
        icon = Icons.cancel_outlined;
        break;
      case 'oculto':
        label = 'Oculto';
        bgColor = Colors.blueGrey.shade100;
        fgColor = Colors.blueGrey.shade900;
        icon = Icons.visibility_off_outlined;
        break;
       case 'fusionado':
         label = 'Fusionado';
         bgColor = Colors.purple.shade100;
         fgColor = Colors.purple.shade900;
         icon = Icons.merge_type_outlined;
         break;
    }

    return Chip(
      avatar: icon != null ? Icon(icon, size: 14, color: fgColor) : null,
      label: Text(label),
      labelStyle: TextStyle(fontSize: 10, color: fgColor, fontWeight: FontWeight.bold),
      backgroundColor: bgColor,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  // Helper para el chip de urgencia (reutilizable)
  Widget _buildUrgencyChip(BuildContext context) {
    if (reporte.urgencia == null) return const SizedBox.shrink();
    String label = reporte.urgencia!;
    Color color = Colors.grey;
    switch (reporte.urgencia!.toLowerCase()) {
      case 'baja': color = Colors.green; break;
      case 'media': color = Colors.orange; break;
      case 'alta': color = Colors.red; break;
    }
    return Chip(
      label: Text(label),
      labelStyle: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      backgroundColor: color.withOpacity(0.15),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool canCancel = reporte.estado == 'pendiente_verificacion' && onCancelar != null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      clipBehavior: Clip.antiAlias, // Para que la imagen se recorte
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Miniatura de imagen (si existe)
            if (reporte.fotoUrl != null)
              Container(
                height: 100, // Altura fija para la miniatura
                width: double.infinity,
                color: Colors.grey.shade300, // Fondo mientras carga o si hay error
                child: Image.network(
                  reporte.fotoUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) =>
                      progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  errorBuilder: (context, error, stack) => const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey)),
                ),
              ),
            // Contenido principal
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fila 1: Estado y Cancelar/Prioridad
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusChip(context),
                      if (canCancel)
                        TextButton(
                          onPressed: onCancelar,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Cancelar', style: TextStyle(fontSize: 12)),
                        )
                      else if (reporte.esPrioritario) // Mostrar estrella si no se puede cancelar y es prioritario
                         Icon(Icons.star_rounded, size: 18, color: Colors.amber.shade700),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Título
                  Text(
                    reporte.titulo,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Fila 2: Categoría y Urgencia
                  Wrap( // Usar Wrap por si los textos son largos
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: [
                      if (reporte.categoria != null)
                         Chip(
                           label: Text(reporte.categoria!),
                           labelStyle: const TextStyle(fontSize: 10),
                           visualDensity: VisualDensity.compact,
                           padding: const EdgeInsets.symmetric(horizontal: 4),
                           backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.7),
                         ),
                      _buildUrgencyChip(context),
                    ],
                  ),
                   const SizedBox(height: 6),

                  // Fila 3: Distrito y Fecha
                  Row(
                    children: [
                      if (reporte.distrito != null) ...[
                        Icon(Icons.location_city_outlined, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded( // Para que el distrito no desborde
                          child: Text(
                            reporte.distrito!,
                            style: theme.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                         const SizedBox(width: 8), // Espacio
                      ],
                      if (reporte.fecha != null) ...[
                         Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
                         const SizedBox(width: 4),
                         Text(reporte.fecha!, style: theme.textTheme.bodySmall),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}