// lib/widgets/verificacion/filtros_historial.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/widgets/verificacion/lista_reportes_verificacion.dart'; // Importa el enum

class FiltrosHistorial extends StatelessWidget {
  final FiltroHistorialEstado filtroHistorialEstado;
  final Function(FiltroHistorialEstado) onEstadoChanged;
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onSelectDateRange;

  const FiltrosHistorial({
    super.key,
    required this.filtroHistorialEstado,
    required this.onEstadoChanged,
    this.startDate,
    this.endDate,
    required this.onSelectDateRange,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd MMM', 'es_ES');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Wrap(
              spacing: 8.0,
              children: FiltroHistorialEstado.values.map((filtro) {
                String label;
                switch(filtro) {
                   case FiltroHistorialEstado.verificado: label = 'Verificados'; break;
                   case FiltroHistorialEstado.rechazado: label = 'Rechazados'; break;
                   case FiltroHistorialEstado.fusionado: label = 'Fusionados'; break;
                   default: label = 'Todos'; break;
                }
                return ChoiceChip(
                  label: Text(label, style: const TextStyle(fontSize: 12)),
                  selected: filtroHistorialEstado == filtro,
                  onSelected: (selected) {
                    if (selected) onEstadoChanged(filtro);
                  },
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(
                startDate != null && endDate != null
                  ? '${dateFormat.format(startDate!)} - ${dateFormat.format(endDate!)}'
                  : 'Seleccionar Fechas',
                style: const TextStyle(fontSize: 12),
              ),
              onPressed: onSelectDateRange,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}