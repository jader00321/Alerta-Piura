// lib/widgets/cerca_de_ti/tarjeta_reporte_cercano.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_cercano_model.dart';

class TarjetaReporteCercano extends StatelessWidget {
  final ReporteCercano reporte;
  final bool isJoining; // Estado de carga para Unirse
  final bool isUnjoining; // Estado de carga para Quitar Apoyo
  final VoidCallback onCardTap;
  final VoidCallback onJoinTap;
  final VoidCallback onUnjoinTap; // Nuevo callback para Quitar Apoyo

  const TarjetaReporteCercano({
    super.key,
    required this.reporte,
    required this.onCardTap,
    required this.onJoinTap,
    required this.onUnjoinTap, // Añadir al constructor
    this.isJoining = false,
    this.isUnjoining = false, // Añadir al constructor
  });

  // Helper para color de urgencia
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

  // Helper para el icono de urgencia
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
    final bool isLoadingAction = isJoining || isUnjoining;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        // Solo navega al detalle si está verificado, de lo contrario onCardTap no hará nada útil
        onTap: isLoadingAction ? null : onCardTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Imagen y Badges Superpuestos ---
            Stack(
              children: [
                if (reporte.fotoUrl != null)
                  Image.network(
                    reporte.fotoUrl!,
                    height: 160, // Ligeramente más alta
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) => progress ==
                            null
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

                // Badges/Chips superpuestos
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
                        backgroundColor: theme.colorScheme.secondaryContainer
                            .withOpacity(0.9),
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
                          backgroundColor: _getUrgencyColor(reporte.urgencia)
                              .withOpacity(0.2),
                        ),
                    ],
                  ),
                ),
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
                    backgroundColor: Colors.black.withOpacity(0.6),
                  ),
                ),
                // Estrella de Prioridad (si aplica)
                if (reporte.esPrioritario)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                    ),
                  ),
              ],
            ),
            // --- Detalles Debajo de la Imagen ---
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Información del Autor y Fecha
                      Expanded(
                        child: Text(
                          'Por ${reporte.autor} • ${reporte.fechaCreacionFormateada}',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Estado y Apoyos Pendientes
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
                  // --- BOTÓN "UNIRSE" CONDICIONAL ---
                  if (esPendiente) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: reporte.usuarioActualUnido
                          ? ElevatedButton.icon(
                              // Botón "UNIDO" (ahora permite quitar apoyo)
                              icon:
                                  isUnjoining // Muestra carga si se está quitando apoyo
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white))
                                      : const Icon(Icons.check_circle,
                                          size: 18), // Icono de check
                              label: Text(
                                reporte.apoyosPendientes > 0
                                    ? 'Unido (+${reporte.apoyosPendientes})'
                                    : 'Unido',
                              ),
                              // Llama a onUnjoinTap al presionar
                              onPressed: isLoadingAction
                                  ? null
                                  : onUnjoinTap, // Deshabilitar si cualquier acción carga
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.green.shade600, // Color verde
                                foregroundColor: Colors.white, // Texto blanco
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8)), // Opcional: bordes menos redondeados
                              ),
                            )
                          : reporte.puedeUnirse
                              ? OutlinedButton.icon(
                                  // Botón "UNIRME"
                                  icon:
                                      isJoining // Muestra carga si se está uniendo
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
                                      color: theme.colorScheme
                                          .primary, // Color primario
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: isLoadingAction
                                      ? null
                                      : onJoinTap, // Llama a onJoinTap
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: theme.colorScheme
                                            .primary), // Borde primario
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                )
                              : ElevatedButton.icon(
                                  // Botón "ES TU REPORTE" (deshabilitado)
                                  icon: const Icon(Icons.person_outline,
                                      size: 18, color: Colors.white70),
                                  label: Text(
                                      reporte.apoyosPendientes > 0
                                          ? 'Es tu reporte (+${reporte.apoyosPendientes})'
                                          : 'Es tu reporte',
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                  onPressed: null, // Siempre deshabilitado
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey
                                          .shade400, // Color azul grisáceo
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8)),
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
