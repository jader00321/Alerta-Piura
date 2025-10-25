// lib/widgets/mi_actividad/tarjeta_actividad.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_resumen_model.dart';
// Asegúrate de que este import sea correcto
import 'package:mobile_app/widgets/mi_actividad/activity_list_view.dart';

/// Una tarjeta reutilizable que muestra un resumen de reporte en
/// las diferentes pestañas de "Mi Actividad". Adapta su apariencia
/// basado en el [Fetcher] (contexto de la pestaña).
class TarjetaActividad extends StatelessWidget {
  final ReporteResumen reporte;
  final Fetcher fetcher; // El contexto (pestaña) desde donde se llama
  final VoidCallback onTap; // Acción al tocar la tarjeta
  final Widget? trailingAction; // Un widget opcional (ej. botón "Cancelar")

  const TarjetaActividad({
    super.key,
    required this.reporte,
    required this.fetcher,
    required this.onTap,
    this.trailingAction, // Acepta la acción del trailing
  });

  // --- Helpers Visuales (Reutilizables) ---

  Widget _buildStatusChip(BuildContext context) {
    // ... (código del _buildStatusChip sin cambios, ya proporcionado) ...
    String label = reporte.estado.toUpperCase();
    Color bgColor = Colors.grey.shade200;
    Color fgColor = Colors.grey.shade800;
    IconData? icon;

    switch (reporte.estado.toLowerCase()) {
      case 'verificado':
        label = 'Verificado'; bgColor = Colors.green.shade100; fgColor = Colors.green.shade900; icon = Icons.check_circle_outline; break;
      case 'pendiente_verificacion':
        label = 'Pendiente'; bgColor = Colors.orange.shade100; fgColor = Colors.orange.shade900; icon = Icons.hourglass_empty_outlined; break;
      case 'rechazado':
        label = 'Rechazado'; bgColor = Colors.red.shade100; fgColor = Colors.red.shade900; icon = Icons.cancel_outlined; break;
      case 'oculto':
        label = 'Oculto'; bgColor = Colors.blueGrey.shade100; fgColor = Colors.blueGrey.shade900; icon = Icons.visibility_off_outlined; break;
       case 'fusionado':
         label = 'Fusionado'; bgColor = Colors.purple.shade100; fgColor = Colors.purple.shade900; icon = Icons.merge_type_outlined; break;
      default: label = reporte.estado; icon = Icons.info_outline; break;
    }
    return Chip(
      avatar: Icon(icon, size: 14, color: fgColor),
      label: Text(label),
      labelStyle: TextStyle(fontSize: 10, color: fgColor, fontWeight: FontWeight.bold),
      backgroundColor: bgColor,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce padding extra
    );
  }

  Widget _buildUrgencyChip(BuildContext context) {
    // ... (código del _buildUrgencyChip sin cambios, ya proporcionado) ...
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
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildContextualRow(BuildContext context, ThemeData theme) {
    // ... (código del _buildContextualRow sin cambios, ya proporcionado) ...
    final contextualBoxDecoration = BoxDecoration(
      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      borderRadius: BorderRadius.circular(8),
    );
    final contextualTextStyle = TextStyle(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
      fontSize: 12,
    );

    switch (fetcher) {
      case Fetcher.misApoyos:
        return Container( padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: contextualBoxDecoration.copyWith( color: Colors.green.shade50, border: Border.all(color: Colors.green.shade200, width: 0.5)), child: Row( mainAxisSize: MainAxisSize.min, children: [ Icon(Icons.thumb_up_alt, size: 14, color: Colors.green.shade700), const SizedBox(width: 6), Text( 'Apoyaste este reporte', style: contextualTextStyle.copyWith(color: Colors.green.shade800), ), ], ), );
      case Fetcher.misSeguimientos:
        return Container( padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: contextualBoxDecoration.copyWith( color: Colors.blue.shade50, border: Border.all(color: Colors.blue.shade200, width: 0.5)), child: Row( mainAxisSize: MainAxisSize.min, children: [ Icon(Icons.bookmark, size: 14, color: Colors.blue.shade700), const SizedBox(width: 6), Text( 'Estás siguiendo este reporte', style: contextualTextStyle.copyWith(color: Colors.blue.shade800), ), ], ), );
      case Fetcher.misComentarios:
        if (reporte.miComentario == null || reporte.miComentario!.isEmpty) return const SizedBox.shrink();
        return Container( width: double.infinity, padding: const EdgeInsets.all(10), decoration: contextualBoxDecoration, child: Text.rich( TextSpan( text: 'Tu comentario: ', style: contextualTextStyle.copyWith(fontWeight: FontWeight.bold), children: [ TextSpan( text: '"${reporte.miComentario!}"', style: contextualTextStyle.copyWith( fontStyle: FontStyle.italic, fontWeight: FontWeight.normal ), ), ] ), maxLines: 2, overflow: TextOverflow.ellipsis, ), );
      case Fetcher.misReportes: return const SizedBox.shrink(); // No contextual row for My Reports
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool showImage = reporte.fotoUrl != null && reporte.fotoUrl!.isNotEmpty;

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
            // --- Imagen y Badges Superpuestos ---
            if (showImage)
              Stack(
                children: [
                  // Imagen
                  Image.network(
                    reporte.fotoUrl!, height: 140, width: double.infinity, fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) => progress == null ? child : const SizedBox(height: 140, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                    errorBuilder: (context, error, stackTrace) => Container( height: 140, color: Colors.grey.shade200, child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey))),
                  ),
                  // Chip de Categoría (Solo si NO es MisReportes O si MisReportes NO tiene imagen)
                  // Para evitar redundancia si la categoría está abajo en MisReportes
                  if (fetcher != Fetcher.misReportes || !showImage)
                     Positioned(
                      top: 8, left: 8,
                      child: Chip(
                        label: Text(reporte.categoria ?? 'Sin Categoría', style: const TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.9),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  // Estrella de Prioridad (Siempre visible si aplica)
                  if (reporte.esPrioritario)
                     Positioned(
                      top: 8, right: 8,
                      child: Container( padding: const EdgeInsets.all(4), decoration: BoxDecoration( color: Colors.black.withOpacity(0.5), shape: BoxShape.circle, ), child: const Icon(Icons.star, color: Colors.amber, size: 20), ),
                    ),
                ],
              ),

            // --- Detalles Debajo ---
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Fila Superior: Estado y (Fecha O Acción Trailing) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start, // Alinea arriba
                    children: [
                      Flexible(child: _buildStatusChip(context)), // Chip de estado
                      const SizedBox(width: 8), // Espacio
                      // Muestra la acción (ej. "Cancelar") si existe, si no, muestra la fecha.
                      trailingAction ??
                        Text(
                          reporte.fecha ?? '', // Fecha de la actividad
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // --- Título ---
                  Text(
                    reporte.titulo,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // --- Información Específica de "Mis Reportes" ---
                  if (fetcher == Fetcher.misReportes) ...[
                    Wrap( // Usa Wrap por si los textos son largos
                      spacing: 8.0,
                      runSpacing: 4.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (reporte.categoria != null)
                           Chip(
                             label: Text(reporte.categoria!), labelStyle: const TextStyle(fontSize: 10),
                             visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 4),
                             backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.7),
                             materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                           ),
                        _buildUrgencyChip(context), // Muestra chip de urgencia
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (reporte.distrito != null)
                      Row(
                        children: [
                           Icon(Icons.location_city_outlined, size: 14, color: Colors.grey[600]),
                           const SizedBox(width: 4),
                           Expanded( // Para que el distrito no desborde
                              child: Text(
                                reporte.distrito!,
                                style: theme.textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                     const SizedBox(height: 4), // Espacio extra
                  ],

                  // --- Autor (si NO es "Mis Reportes") ---
                  if (fetcher != Fetcher.misReportes && reporte.autor != null)
                    Padding( // Añade padding
                      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                      child: Text(
                        'Reporte original de: ${reporte.autor}',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  // --- Separador y Fila Contextual ---
                  // Solo muestra Divider si hay fila contextual O si no es "Mis Reportes"
                  if (fetcher != Fetcher.misReportes)
                     const Divider(height: 16),

                  _buildContextualRow(context, theme), // Muestra la fila de apoyo/seguimiento/comentario

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}