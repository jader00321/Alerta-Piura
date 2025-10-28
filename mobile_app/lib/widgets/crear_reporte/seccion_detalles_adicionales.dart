import 'package:flutter/material.dart';

/// {@template seccion_detalles_adicionales}
/// Widget reutilizable que agrupa los campos de entrada *adicionales u opcionales*
/// para el formulario de creación/edición de reportes ([CreateReportScreen], [PantallaEditarReporteAutor]).
///
/// Incluye campos para:
/// - Descripción (Opcional)
/// - Distrito (Requerido)
/// - Referencia de Ubicación (Opcional)
/// - Hora del Incidente (Opcional)
/// - Impacto del Problema
/// - Etiquetas (Tags) y sugerencias de tags.
/// {@endtemplate}
class SeccionDetallesAdicionales extends StatelessWidget {
  /// Controlador para el campo 'Descripción'.
  final TextEditingController descripcionController;
  /// Controlador para el campo 'Referencia de Ubicación'.
  final TextEditingController referenciaController;
  /// El valor actual seleccionado en el dropdown 'Distrito'.
  final String? distritoSeleccionado;
  /// La lista de strings para poblar el dropdown 'Distrito'.
  final List<String> distritos;
  /// Callback que se ejecuta cuando se selecciona un nuevo distrito.
  final Function(String?) onDistritoChanged;
  /// La hora del incidente seleccionada (o `null`).
  final TimeOfDay? horaIncidente;
  /// Callback que se ejecuta para mostrar el selector de hora.
  final VoidCallback onSelectTime;
  /// El valor actual seleccionado en el dropdown 'Impacto'.
  final String impactoSeleccionado;
  /// Callback que se ejecuta cuando se selecciona un nuevo impacto.
  final Function(String?) onImpactoChanged;
  /// Controlador para el campo de texto 'Etiquetas'.
  final TextEditingController tagsController;
  /// Lista de strings para mostrar como [ActionChip]s de sugerencia.
  final List<String> recommendedTags;
  /// Callback que se ejecuta al presionar un chip de etiqueta sugerida.
  final Function(String) onAddTag;

  /// {@macro seccion_detalles_adicionales}
  const SeccionDetallesAdicionales({
    super.key,
    required this.descripcionController,
    required this.referenciaController,
    this.distritoSeleccionado,
    required this.distritos,
    required this.onDistritoChanged,
    this.horaIncidente,
    required this.onSelectTime,
    required this.impactoSeleccionado,
    required this.onImpactoChanged,
    required this.tagsController,
    required this.recommendedTags,
    required this.onAddTag,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detalles Adicionales',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            /// Campo Descripción (Opcional).
            TextFormField(
              controller: descripcionController,
              decoration: const InputDecoration(
                  labelText: 'Descripción (Opcional)',
                  border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            /// Campo Distrito (Requerido).
            DropdownButtonFormField<String>(
              value: distritoSeleccionado,
              decoration: const InputDecoration(
                  labelText: 'Distrito', border: OutlineInputBorder()),
              items: distritos.map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: onDistritoChanged,
              validator: (value) => value == null ? 'Selecciona un distrito' : null,
            ),
            const SizedBox(height: 16),
            /// Campo Referencia (Opcional).
            TextFormField(
              controller: referenciaController,
              decoration: const InputDecoration(
                  labelText: 'Referencia de Ubicación (Opcional)',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            /// Selector de Hora (Opcional).
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Hora del Incidente (Opcional)'),
              subtitle: Text(horaIncidente?.format(context) ?? 'No seleccionada'),
              trailing: const Icon(Icons.access_time),
              onTap: onSelectTime, // Llama al callback del padre.
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            /// Campo Impacto (Requerido, con valor por defecto).
            DropdownButtonFormField<String>(
              value: impactoSeleccionado,
              decoration: const InputDecoration(
                  labelText: 'Impacto del Problema',
                  border: OutlineInputBorder()),
              items: ['Solo a mí', 'A mi calle', 'A todo el barrio']
                  .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                  .toList(),
              onChanged: onImpactoChanged,
            ),
            const SizedBox(height: 16),
            /// Campo Etiquetas (Opcional).
            TextFormField(
              controller: tagsController,
              decoration: const InputDecoration(
                labelText: 'Etiquetas (separadas por coma)',
                helperText: 'Ayudan a clasificar mejor tu reporte.',
                border: OutlineInputBorder(),
              ),
            ),
            /// Chips de Etiquetas Recomendadas.
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Wrap(
                spacing: 8.0,
                children: recommendedTags
                    .map((tag) => ActionChip(
                          label: Text(tag),
                          onPressed: () => onAddTag(tag), // Llama al callback
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}