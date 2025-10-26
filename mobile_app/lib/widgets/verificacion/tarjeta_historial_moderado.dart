import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_historial_moderado_model.dart';

class TarjetaHistorialModerado extends StatelessWidget {
  final ReporteHistorialModerado reporte;
  final String? estadoSolicitud;
  final VoidCallback onTap;
  final VoidCallback onSolicitarRevision;
  final VoidCallback? onIrAlOriginal;

  const TarjetaHistorialModerado({
    super.key,
    required this.reporte,
    required this.estadoSolicitud,
    required this.onTap,
    required this.onSolicitarRevision,
    this.onIrAlOriginal,
  });

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
      labelStyle:
          TextStyle(color: fgColor, fontWeight: FontWeight.bold, fontSize: 10),
      backgroundColor: bgColor,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool puedeSolicitarRevision = reporte.estado == 'verificado' ||
        reporte.estado == 'rechazado' ||
        reporte.estado == 'fusionado';

    Widget? trailingWidget;
    List<Widget> trailingWidgets = [];

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
          break;
        case 'desestimada':
        default:
          trailingWidgets.add(TextButton(
            onPressed: onSolicitarRevision,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Solicitar Revisión',
                style: TextStyle(fontSize: 12)),
          ));
          break;
      }
    }

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

    if (trailingWidgets.isEmpty) {
      trailingWidget = null;
    } else if (trailingWidgets.length == 1) {
      trailingWidget = trailingWidgets.first;
    } else {
      trailingWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          trailingWidgets[0],
          const SizedBox(width: 4),
          trailingWidgets[1],
        ],
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: ListTile(
        title: Text(reporte.titulo,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        subtitle: Text('${reporte.categoria} • ${reporte.fecha}',
            style: const TextStyle(fontSize: 12)),
        leading: _buildStatusChip(theme),
        trailing: trailingWidget,
        onTap: onTap,
      ),
    );
  }
}
