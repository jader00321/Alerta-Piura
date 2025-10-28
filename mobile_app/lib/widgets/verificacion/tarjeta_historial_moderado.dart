import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_historial_moderado_model.dart';

/// {@template tarjeta_historial_moderado}
/// Widget que representa una tarjeta para mostrar un reporte ya moderado
/// en la lista del historial del líder ([ListaReportesVerificacion]).
///
/// Muestra el estado final, título, categoría y fecha de moderación.
/// Incluye lógica condicional para mostrar un botón "Solicitar Revisión"
/// o el estado de una solicitud ya enviada ([estadoSolicitud]).
/// También puede mostrar un botón para ir al reporte original si fue fusionado.
/// {@endtemplate}
class TarjetaHistorialModerado extends StatelessWidget {
  /// Los datos del reporte moderado a mostrar.
  final ReporteHistorialModerado reporte;
  /// El estado actual de la solicitud de revisión para este reporte
  /// ('pendiente', 'aprobada', 'desestimada', o `null` si no hay solicitud).
  final String? estadoSolicitud;
  /// Callback que se ejecuta al tocar la tarjeta (para ver detalles).
  final VoidCallback onTap;
  /// Callback que se ejecuta al presionar "Solicitar Revisión".
  final VoidCallback onSolicitarRevision;
  /// Callback opcional que se ejecuta al presionar el ícono de enlace
  /// en reportes fusionados (para navegar al reporte original).
  final VoidCallback? onIrAlOriginal;

  /// {@macro tarjeta_historial_moderado}
  const TarjetaHistorialModerado({
    super.key,
    required this.reporte,
    required this.estadoSolicitud,
    required this.onTap,
    required this.onSolicitarRevision,
    this.onIrAlOriginal,
  });

  /// Construye el chip que muestra el estado final de la moderación.
  Widget _buildStatusChip(ThemeData theme) {
    String label;
    IconData icon;
    Color fgColor;
    Color bgColor;
    switch (reporte.estado) {
      case 'verificado':
        label = 'Verificado';
        icon = Icons.check_circle_outline;
        fgColor = Colors.green.shade900;
        bgColor = Colors.green.shade100;
        break;
      case 'rechazado':
        label = 'Rechazado';
        icon = Icons.cancel_outlined;
        fgColor = Colors.red.shade900;
        bgColor = Colors.red.shade100;
        break;
      case 'fusionado':
        label = 'Fusionado';
        icon = Icons.merge_type_outlined;
        fgColor = Colors.purple.shade900;
        bgColor = Colors.purple.shade100;
        break;
      default:
        label = reporte.estado;
        icon = Icons.help_outline;
        fgColor = Colors.grey.shade700;
        bgColor = Colors.grey.shade200;
        break;
    }
    return Chip(
      avatar: Icon(icon, size: 14, color: fgColor),
      label: Text(label),
      labelStyle: TextStyle(
          color: fgColor, fontWeight: FontWeight.bold, fontSize: 10),
      backgroundColor: bgColor,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Determina si se puede solicitar revisión basado en el estado del reporte.
    final bool puedeSolicitarRevision = reporte.estado == 'verificado' ||
        reporte.estado == 'rechazado' ||
        reporte.estado == 'fusionado';

    Widget? trailingWidget;
    List<Widget> trailingWidgets = [];

    // Lógica para el botón/estado de "Solicitar Revisión".
    if (puedeSolicitarRevision) {
      switch (estadoSolicitud) {
        case 'pendiente':
          trailingWidgets.add(Chip(
            label: const Text('Solicitud Enviada'),
            labelStyle:
                TextStyle(fontSize: 10, color: Colors.blueGrey.shade700),
            backgroundColor: Colors.blueGrey.shade100,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ));
          break;
        case 'aprobada':
          // No muestra nada si ya fue aprobada.
          break;
        case 'desestimada':
        // Si no hay solicitud o fue desestimada, muestra el botón.
        default:
          trailingWidgets.add(TextButton(
            onPressed: onSolicitarRevision,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child:
                const Text('Solicitar Revisión', style: TextStyle(fontSize: 12)),
          ));
          break;
      }
    }

    // Lógica para el botón de enlace (solo si está fusionado y hay callback).
    if (reporte.estado == 'fusionado' && onIrAlOriginal != null) {
      trailingWidgets.add(Tooltip(
        message: 'Ir al reporte original',
        child: IconButton(
          icon: Icon(Icons.link, color: Colors.purple.shade300),
          onPressed: onIrAlOriginal,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ));
    }

    // Combina los widgets del trailing si hay más de uno.
    if (trailingWidgets.isEmpty) {
      trailingWidget = null;
    } else if (trailingWidgets.length == 1) {
      trailingWidget = trailingWidgets.first;
    } else {
      // Muestra ambos widgets (estado solicitud y enlace) si aplican.
      trailingWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          trailingWidgets[0],
          const SizedBox(width: 4),
          trailingWidgets[1],
        ],
      );
    }

    // Construye el ListTile principal.
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: ListTile(
        title: Text(reporte.titulo,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        subtitle: Text('${reporte.categoria} • ${reporte.fecha}',
            style: const TextStyle(fontSize: 12)),
        leading: _buildStatusChip(theme), // Muestra el chip de estado.
        trailing: trailingWidget, // Muestra las acciones/estado calculados.
        onTap: onTap, // Permite navegar al detalle.
      ),
    );
  }
}