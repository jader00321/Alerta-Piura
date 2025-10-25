import 'package:flutter/material.dart';

class SeccionDetallesAdicionales extends StatelessWidget {
  final TextEditingController descripcionController;
  final TextEditingController referenciaController;
  final String? distritoSeleccionado;
  final List<String> distritos;
  final Function(String?) onDistritoChanged;
  final TimeOfDay? horaIncidente;
  final VoidCallback onSelectTime;
  final String impactoSeleccionado;
  final Function(String?) onImpactoChanged;
  final TextEditingController tagsController;
  final List<String> recommendedTags;
  final Function(String) onAddTag;

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
            Text('Detalles Adicionales', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción (Opcional)', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: distritoSeleccionado,
              decoration: const InputDecoration(labelText: 'Distrito', border: OutlineInputBorder()),
              items: distritos.map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: onDistritoChanged,
              validator: (value) => value == null ? 'Selecciona un distrito' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: referenciaController,
              decoration: const InputDecoration(labelText: 'Referencia de Ubicación (Opcional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Hora del Incidente (Opcional)'),
              subtitle: Text(horaIncidente?.format(context) ?? 'No seleccionada'),
              trailing: const Icon(Icons.access_time),
              onTap: onSelectTime,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: impactoSeleccionado,
              decoration: const InputDecoration(labelText: 'Impacto del Problema', border: OutlineInputBorder()),
              items: ['Solo a mí', 'A mi calle', 'A todo el barrio']
                  .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                  .toList(),
              onChanged: onImpactoChanged,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: tagsController,
              decoration: const InputDecoration(
                labelText: 'Etiquetas (separadas por coma)',
                helperText: 'Ayudan a clasificar mejor tu reporte.',
                border: OutlineInputBorder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Wrap(
                spacing: 8.0,
                children: recommendedTags.map((tag) => ActionChip(
                  label: Text(tag),
                  onPressed: () => onAddTag(tag),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}