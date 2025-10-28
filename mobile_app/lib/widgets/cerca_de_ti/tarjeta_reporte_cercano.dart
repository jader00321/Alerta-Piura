import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_cercano_model.dart';

/// {@template tarjeta_reporte_cercano}
/// Tarjeta que muestra un resumen de un reporte cercano en la lista
/// de [PantallaCercaDeTi].
///
/// Muestra información clave como imagen, título, categoría, urgencia, distancia,
/// autor y estado.
///
/// La característica principal es el **botón de acción dinámico** para reportes
/// en estado 'pendiente_verificacion':
/// - Muestra "Unirme (+X)" si [reporte.puedeUnirse] es `true`.
/// - Muestra "Unido (+X)" si [reporte.usuarioActualUnido] es `true`.
/// - Muestra "Es tu reporte" (deshabilitado) si el usuario es el autor.
///
/// Maneja los estados de carga [isJoining] y [isUnjoining] para los botones.
/// {@endtemplate}
class TarjetaReporteCercano extends StatelessWidget {
  /// Los datos del reporte cercano a mostrar.
  final ReporteCercano reporte;
  /// Indica si se está procesando la acción de "unirse".
  final bool isJoining;
  /// Indica si se está procesando la acción de "quitar apoyo".
  final bool isUnjoining;
  /// Callback al tocar cualquier parte de la tarjeta.
  final VoidCallback onCardTap;
  /// Callback al presionar el botón "Unirme".
  final VoidCallback onJoinTap;
  /// Callback al presionar el botón "Unido" (para quitar apoyo).
  final VoidCallback onUnjoinTap;

  /// {@macro tarjeta_reporte_cercano}
  const TarjetaReporteCercano({
    super.key,
    required this.reporte,
    required this.onCardTap,
    required this.onJoinTap,
    required this.onUnjoinTap,
    this.isJoining = false,
    this.isUnjoining = false,
  });

  /// Helper para determinar el color basado en la urgencia.
  Color _getUrgencyColor(String? urgency) {
    switch (urgency?.toLowerCase()) {
      case 'alta':
        return Colors.red.shade600;
      case 'media':
        return Colors.orange.shade700;
      case 'baja':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  /// Helper para determinar el icono basado en la urgencia.
  IconData _getUrgencyIcon(String? urgency) {
    switch (urgency?.toLowerCase()) {
      case 'alta':
        return Icons.priority_high_rounded;
      case 'media':
        return Icons.warning_amber_rounded;
      case 'baja':
        return Icons.low_priority_rounded;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool esPendiente = reporte.estado == 'pendiente_verificacion';
    /// Flag para deshabilitar botones si cualquier acción está en progreso.
    final bool isLoadingAction = isJoining || isUnjoining;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: isLoadingAction ? null : onCardTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Sección de Imagen y Chips superpuestos.
            Stack(
              children: [
                /// Imagen del reporte (o placeholder).
                if (reporte.fotoUrl != null)
                  Image.network(
                    reporte.fotoUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) => progress == null
                        ? child
                        : const SizedBox(
                            height: 160,
                            child: Center(child: CircularProgressIndicator())),
                    errorBuilder: (context, error, stackTrace) => Container(
                        height: 160,
                        color: Colors.grey.shade200,
                        child: const Center(
                            child: Icon(Icons.broken_image,
                                size: 40, color: Colors.grey))),
                  )
                else
                  Container(
                      height: 160,
                      color: Colors.grey.shade200,
                      child: Center(
                          child: Icon(Icons.image_not_supported,
                              size: 40, color: Colors.grey.shade400))),

                /// Chips de Categoría y Urgencia (arriba a la izquierda).
                Positioned(
                  top: 8,
                  left: 8,
                  child: Wrap(
                    spacing: 4.0,
                    children: [
                      Chip(
                        label: Text(reporte.categoria,
                            style: const TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 0),
                        backgroundColor:
                            theme.colorScheme.secondaryContainer.withAlpha(230),
                      ),
                      if (reporte.urgencia != null)
                        Chip(
                          avatar: Icon(_getUrgencyIcon(reporte.urgencia),
                              size: 14,
                              color: _getUrgencyColor(reporte.urgencia)),
                          label: Text(reporte.urgencia!,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: _getUrgencyColor(reporte.urgencia),
                                  fontWeight: FontWeight.bold)),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 0),
                          backgroundColor:
                              _getUrgencyColor(reporte.urgencia).withAlpha(38),
                        ),
                    ],
                  ),
                ),

                /// Chip de Distancia (arriba a la derecha).
                Positioned(
                  top: 8,
                  right: 8,
                  child: Chip(
                    label: Text(
                      '~${reporte.distanciaMetros.toStringAsFixed(0)}m',
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                    visualDensity: VisualDensity.compact,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    backgroundColor: Colors.black.withAlpha(153),
                  ),
                ),

                /// Icono de Prioridad (abajo a la derecha).
                if (reporte.esPrioritario)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(128),
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                    ),
                  ),
              ],
            ),

            /// Sección de Detalles Textuales.
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reporte.titulo,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  /// Fila de Autor/Fecha y Estado.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Por ${reporte.autor} • ${reporte.fechaCreacionFormateada}',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        avatar: Icon(
                          esPendiente
                              ? Icons.hourglass_empty_outlined
                              : Icons.check_circle_outline,
                          size: 16,
                          color: esPendiente
                              ? Colors.orange.shade800
                              : Colors.green.shade800,
                        ),
                        label: Text(esPendiente ? 'Pendiente' : 'Verificado',
                            style: const TextStyle(fontSize: 11)),
                        backgroundColor: esPendiente
                            ? Colors.orange.shade100
                            : Colors.green.shade100,
                        labelStyle: TextStyle(
                          color: esPendiente
                              ? Colors.orange.shade800
                              : Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 0),
                      ),
                    ],
                  ),
                  /// Botón de Acción Dinámico (solo para reportes pendientes).
                  if (esPendiente) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: reporte.usuarioActualUnido
                          /// Caso 1: El usuario ya se unió. Muestra botón "Unido".
                          ? ElevatedButton.icon(
                              icon: isUnjoining
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.check_circle, size: 18),
                              label: Text(
                                reporte.apoyosPendientes > 0
                                    ? 'Unido (+${reporte.apoyosPendientes})'
                                    : 'Unido',
                              ),
                              onPressed: isLoadingAction ? null : onUnjoinTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            )
                          : reporte.puedeUnirse
                              /// Caso 2: El usuario puede unirse. Muestra botón "Unirme".
                              ? OutlinedButton.icon(
                                  icon: isJoining
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2))
                                      : const Icon(Icons.add, size: 18),
                                  label: Text(
                                    reporte.apoyosPendientes > 0
                                        ? 'Unirme (+${reporte.apoyosPendientes})'
                                        : '¡Yo también! Unirme',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: isLoadingAction ? null : onJoinTap,
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: theme.colorScheme.primary),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                )
                              /// Caso 3: El usuario es el autor. Muestra botón deshabilitado.
                              : ElevatedButton.icon(
                                  icon: const Icon(Icons.person_outline,
                                      size: 18, color: Colors.white70),
                                  label: Text(
                                      reporte.apoyosPendientes > 0
                                          ? 'Es tu reporte (+${reporte.apoyosPendientes})'
                                          : 'Es tu reporte',
                                      style:
                                          const TextStyle(color: Colors.white70)),
                                  onPressed: null, // Deshabilitado
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey.shade400,
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 8)),
                                ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}