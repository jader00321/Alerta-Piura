import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_resumen_model.dart';
import 'package:mobile_app/widgets/mi_actividad/activity_list_view.dart'; // Importa el enum Fetcher

/// {@template tarjeta_actividad}
/// Tarjeta **reutilizable y unificada** que muestra un resumen de reporte
/// adaptado al contexto de las diferentes pestañas de la pantalla [MiActividadScreen].
///
/// Adapta su apariencia basándose en el [fetcher] (contexto de la pestaña) para mostrar:
/// - Imagen, estado, título.
/// - Categoría, Urgencia, Distrito (principalmente para [Fetcher.misReportes]).
/// - Autor del reporte (para [Fetcher.misApoyos], [Fetcher.misSeguimientos], [Fetcher.misComentarios]).
/// - Una "fila contextual" que indica la acción del usuario (Apoyaste, Siguiendo, Tu comentario).
/// - Acepta un [trailingAction] opcional (ej. botón "Cancelar" para reportes pendientes).
/// {@endtemplate}
class TarjetaActividad extends StatelessWidget {
  /// Los datos resumidos del reporte a mostrar.
  final ReporteResumen reporte;
  /// El contexto ([Fetcher]) que indica desde qué pestaña se está mostrando la tarjeta.
  final Fetcher fetcher;
  /// Callback que se ejecuta al tocar la tarjeta (navega al detalle).
  final VoidCallback onTap;
  /// Widget opcional que se muestra en el área del trailing (ej. botón cancelar).
  final Widget? trailingAction;

  /// {@macro tarjeta_actividad}
  const TarjetaActividad({
    super.key,
    required this.reporte,
    required this.fetcher,
    required this.onTap,
    this.trailingAction, // Acepta la acción del trailing
  });

  /// Construye el chip que muestra el estado del reporte con icono y color.
  Widget _buildStatusChip(BuildContext context) {
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
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  /// Construye el chip que muestra la urgencia del reporte con color.
  Widget _buildUrgencyChip(BuildContext context) {
    if (reporte.urgencia == null) {
      return const SizedBox.shrink(); // No muestra nada si no hay urgencia
    }
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
      backgroundColor: color.withAlpha(38), // Fondo semitransparente
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  /// Construye la fila contextual que varía según la pestaña ([fetcher]).
  /// Muestra "Apoyaste", "Siguiendo" o "Tu comentario: ...".
  Widget _buildContextualRow(BuildContext context, ThemeData theme) {
    // Estilos comunes para la fila contextual.
    final contextualBoxDecoration = BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest.withAlpha(102),
      borderRadius: BorderRadius.circular(8),
    );
    final contextualTextStyle = TextStyle(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
      fontSize: 12,
    );

    // Determina qué mostrar según el contexto.
    switch (fetcher) {
      case Fetcher.misApoyos:
        // Muestra un indicador de que el usuario apoyó este reporte.
        return Container( padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: contextualBoxDecoration.copyWith( color: Colors.green.shade50, border: Border.all(color: Colors.green.shade200, width: 0.5)), child: Row( mainAxisSize: MainAxisSize.min, children: [ Icon(Icons.thumb_up_alt, size: 14, color: Colors.green.shade700), const SizedBox(width: 6), Text( 'Apoyaste este reporte', style: contextualTextStyle.copyWith(color: Colors.green.shade800), ), ], ), );
      case Fetcher.misSeguimientos:
        // Muestra un indicador de que el usuario sigue este reporte.
        return Container( padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: contextualBoxDecoration.copyWith( color: Colors.blue.shade50, border: Border.all(color: Colors.blue.shade200, width: 0.5)), child: Row( mainAxisSize: MainAxisSize.min, children: [ Icon(Icons.bookmark, size: 14, color: Colors.blue.shade700), const SizedBox(width: 6), Text( 'Estás siguiendo este reporte', style: contextualTextStyle.copyWith(color: Colors.blue.shade800), ), ], ), );
      case Fetcher.misComentarios:
        // Muestra un extracto del comentario del usuario en este reporte.
        if (reporte.miComentario == null || reporte.miComentario!.isEmpty) {
          return const SizedBox.shrink(); // No muestra nada si no hay comentario
        }
        return Container( width: double.infinity, padding: const EdgeInsets.all(10), decoration: contextualBoxDecoration, child: Text.rich( TextSpan( text: 'Tu comentario: ', style: contextualTextStyle.copyWith(fontWeight: FontWeight.bold), children: [ TextSpan( text: '"${reporte.miComentario!}"', style: contextualTextStyle.copyWith( fontStyle: FontStyle.italic, fontWeight: FontWeight.normal ), ), ] ), maxLines: 2, overflow: TextOverflow.ellipsis, ), );
      case Fetcher.misReportes:
        // No muestra fila contextual en la pestaña "Mis Reportes".
        return const SizedBox.shrink();
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
        onTap: onTap, // Navega al detalle al tocar la tarjeta.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Muestra la imagen si existe.
            if (showImage)
              Stack(
                children: [
                  Image.network(
                    reporte.fotoUrl!, height: 140, width: double.infinity, fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) => progress == null ? child : const SizedBox(height: 140, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                    errorBuilder: (context, error, stackTrace) => Container( height: 140, color: Colors.grey.shade200, child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey))),
                  ),
                  /// Muestra la categoría sobre la imagen si no es "Mis Reportes".
                  if (fetcher != Fetcher.misReportes || !showImage) // Evita redundancia si ya se muestra abajo
                     Positioned(
                      top: 8, left: 8,
                      child: Chip(
                        label: Text(reporte.categoria ?? 'Sin Categoría', style: const TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        backgroundColor: theme.colorScheme.secondaryContainer.withAlpha(230),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  /// Muestra estrella si es prioritario.
                  if (reporte.esPrioritario)
                     Positioned(
                      top: 8, right: 8,
                      child: Container( padding: const EdgeInsets.all(4), decoration: BoxDecoration( color: Colors.black.withAlpha(128), shape: BoxShape.circle, ), child: const Icon(Icons.star, color: Colors.amber, size: 20), ),
                    ),
                ],
              ),
            /// Contenedor de los detalles textuales.
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Fila 1: Chip de estado y acción trailing (ej. botón Cancelar o fecha).
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start, // Alinea arriba
                    children: [
                      Flexible(child: _buildStatusChip(context)), // Chip de Estado
                      const SizedBox(width: 8),
                      // Muestra la acción (ej. Cancelar) o la fecha por defecto.
                      trailingAction ??
                        Text(
                          reporte.fecha ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  /// Título del reporte.
                  Text(
                    reporte.titulo,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  /// Fila 2: Chips de Categoría y Urgencia (solo para "Mis Reportes").
                  if (fetcher == Fetcher.misReportes) ...[
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (reporte.categoria != null)
                           Chip(
                             label: Text(reporte.categoria!), labelStyle: const TextStyle(fontSize: 10),
                             visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 4),
                             backgroundColor: theme.colorScheme.secondaryContainer.withAlpha(179),
                             materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                           ),
                        _buildUrgencyChip(context), // Chip de Urgencia
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],

                  /// Fila 3: Distrito (solo para "Mis Reportes").
                  if (fetcher == Fetcher.misReportes && reporte.distrito != null) ...[
                      Row(
                        children: [
                           Icon(Icons.location_city_outlined, size: 14, color: Colors.grey[600]),
                           const SizedBox(width: 4),
                           Expanded( // Evita que el nombre del distrito desborde
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

                  /// Muestra el autor del reporte si NO estamos en "Mis Reportes".
                  if (fetcher != Fetcher.misReportes && reporte.autor != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                      child: Text(
                        'Reporte original de: ${reporte.autor}',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  /// Separador y Fila Contextual.
                  // Muestra el divisor si hay fila contextual o si no es "Mis Reportes".
                  if (fetcher != Fetcher.misReportes) const Divider(height: 16),

                  // Muestra la fila de apoyo/seguimiento/comentario según el contexto.
                  _buildContextualRow(context, theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}