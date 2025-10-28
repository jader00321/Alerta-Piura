import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/widgets/verificacion/lista_reportes_verificacion.dart'; // Importa el enum FiltroHistorialEstado

/// {@template filtros_historial}
/// Widget que muestra los controles de filtro para la lista del historial de moderación.
///
/// Permite filtrar por estado ([FiltroHistorialEstado]) usando [ChoiceChip]
/// y por rango de fechas mediante un [TextButton] que abre un selector de fechas
/// (la lógica del selector está en el widget padre [ListaReportesVerificacion]).
/// {@endtemplate}
class FiltrosHistorial extends StatelessWidget {
  /// El estado de filtro actualmente seleccionado.
  final FiltroHistorialEstado filtroHistorialEstado;
  /// Callback que se ejecuta cuando se selecciona un nuevo estado.
  final Function(FiltroHistorialEstado) onEstadoChanged;
  /// La fecha de inicio del rango seleccionado (opcional).
  final DateTime? startDate;
  /// La fecha de fin del rango seleccionado (opcional).
  final DateTime? endDate;
  /// Callback que se ejecuta al presionar el botón de selección de fechas.
  final VoidCallback onSelectDateRange;

  /// {@macro filtros_historial}
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
    // Formateador para mostrar las fechas seleccionadas en el botón.
    final DateFormat dateFormat = DateFormat('dd MMM', 'es_ES');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      // Permite scroll horizontal si los filtros no caben en pantalla.
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            /// Chips para seleccionar el estado del reporte.
            Wrap(
              spacing: 8.0,
              children: FiltroHistorialEstado.values.map((filtro) {
                // Mapea el enum a una etiqueta legible.
                String label;
                switch (filtro) {
                  case FiltroHistorialEstado.verificado: label = 'Verificados'; break;
                  case FiltroHistorialEstado.rechazado: label = 'Rechazados'; break;
                  case FiltroHistorialEstado.fusionado: label = 'Fusionados'; break;
                  default: label = 'Todos'; break;
                }
                return ChoiceChip(
                  label: Text(label, style: const TextStyle(fontSize: 12)),
                  selected: filtroHistorialEstado == filtro,
                  onSelected: (selected) {
                    if (selected) {
                      onEstadoChanged(filtro); // Llama al callback del padre
                    }
                  },
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
            const SizedBox(width: 16),
            /// Botón para abrir el selector de rango de fechas.
            TextButton.icon(
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(
                // Muestra el rango seleccionado o texto por defecto.
                startDate != null && endDate != null
                    ? '${dateFormat.format(startDate!)} - ${dateFormat.format(endDate!)}'
                    : 'Seleccionar Fechas',
                style: const TextStyle(fontSize: 12),
              ),
              onPressed: onSelectDateRange, // Llama al callback del padre
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