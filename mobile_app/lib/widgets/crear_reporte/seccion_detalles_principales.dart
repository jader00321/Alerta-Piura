import 'package:flutter/material.dart';
import 'package:mobile_app/models/categoria_model.dart';

class SeccionDetallesPrincipales extends StatelessWidget {
  final TextEditingController tituloController;
  final String urgenciaSeleccionada;
  final Function(String) onUrgenciaChanged;
  final int? categoriaSeleccionada;
  final List<Categoria> categorias;
  final bool isLoadingCategories;
  final Function(int?) onCategoriaChanged;
  final int otroCategoriaId;
  final TextEditingController categoriaSugeridaController;
  final bool isEditing;

  const SeccionDetallesPrincipales({
    super.key,
    required this.tituloController,
    required this.urgenciaSeleccionada,
    required this.onUrgenciaChanged,
    required this.categoriaSeleccionada,
    required this.categorias,
    required this.isLoadingCategories,
    required this.onCategoriaChanged,
    required this.otroCategoriaId,
    required this.categoriaSugeridaController,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool mostrarSugerencia = categoriaSeleccionada == otroCategoriaId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: tituloController,
          decoration: const InputDecoration(
            labelText: 'Título del Reporte *',
            hintText: 'Ej. Bache peligroso en Av. Grau',
            border: OutlineInputBorder(),
          ),
          validator: (value) => (value == null || value.trim().isEmpty)
              ? 'El título es requerido'
              : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: urgenciaSeleccionada,
          decoration: const InputDecoration(
            labelText: 'Nivel de Urgencia *',
            border: OutlineInputBorder(),
          ),
          items: ['Baja', 'Media', 'Alta']
              .map(
                  (label) => DropdownMenuItem(value: label, child: Text(label)))
              .toList(),
          onChanged: (value) => onUrgenciaChanged(value!),
        ),
        const SizedBox(height: 16),
        isLoadingCategories
            ? const Center(
                child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator()))
            : DropdownButtonFormField<int>(
                value: categoriaSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Categoría *',
                  border: OutlineInputBorder(),
                ),
                items: categorias
                    .map((cat) => DropdownMenuItem(
                        value: cat.id, child: Text(cat.nombre)))
                    .toList(),
                onChanged: onCategoriaChanged,
                validator: (value) =>
                    value == null ? 'Selecciona una categoría' : null,
              ),
        const SizedBox(height: 16),
        if (mostrarSugerencia)
          TextFormField(
            controller: categoriaSugeridaController,
            decoration: const InputDecoration(
              labelText: 'Especifica la categoría *',
              hintText: 'Ej. Poste caído, Semáforo malogrado',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (mostrarSugerencia &&
                  (value == null || value.trim().isEmpty)) {
                return 'Debes sugerir una categoría si eliges "Otro"';
              }
              return null;
            },
          ),
      ],
    );
  }
}
