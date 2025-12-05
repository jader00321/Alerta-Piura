import 'package:flutter/material.dart';
import 'package:mobile_app/models/analiticas_reportero_model.dart';

class TarjetaIndicadorEficiencia extends StatelessWidget {
  final TiemposAtencion tiempos;

  const TarjetaIndicadorEficiencia({super.key, required this.tiempos});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final horas = double.tryParse(tiempos.tiempoPromedioHoras) ?? 0;
    
    Color statusColor = Colors.green;
    String statusText = "Eficiente";
    IconData statusIcon = Icons.check_circle_outline;

    if (horas > 24) {
      statusColor = Colors.orange;
      statusText = "Regular";
      statusIcon = Icons.warning_amber_rounded;
    }
    if (horas > 48) {
      statusColor = Colors.red;
      statusText = "Lento";
      statusIcon = Icons.error_outline;
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Velocidad de Atención", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${tiempos.tiempoPromedioHoras} hrs", 
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: statusColor)),
                    Text("Tiempo promedio de respuesta", style: theme.textTheme.bodySmall),
                  ],
                ),
                Column(
                  children: [
                    Icon(statusIcon, size: 32, color: statusColor),
                    const SizedBox(height: 4),
                    Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),
             // DESCRIPCIÓN DETALLADA
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Mide el tiempo transcurrido desde que un ciudadano envía un reporte hasta que es verificado o rechazado por un líder vecinal. Un tiempo menor indica una gestión comunitaria ágil.",
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}