import 'package:flutter/material.dart';
import 'package:mobile_app/models/categoria_model.dart';

/// {@template seccion_detalles_principales}
/// Widget reutilizable que agrupa los campos de entrada *principales y requeridos*
/// para el formulario de creación/edición de reportes.
///
/// Incluye campos para:
/// - Título
/// - Nivel de Urgencia
/// - Categoría (con un [DropdownButtonFormField] poblado desde [categorias])
/// - Campo condicional para "Sugerir Categoría" si se selecciona "Otro".
///
/// Usado en [CreateReportScreen] y [PantallaEditarReporteAutor].
/// {@endtemplate}
class SeccionDetallesPrincipales extends StatelessWidget {
  /// Controlador para el campo 'Título'.
  final TextEditingController tituloController;
  /// Valor actual seleccionado en el dropdown 'Urgencia'.
  final String urgenciaSeleccionada;
  /// Callback que se ejecuta al cambiar la urgencia.
  final Function(String) onUrgenciaChanged;
  /// ID de la categoría actualmente seleccionada.
  final int? categoriaSeleccionada;
  /// Lista de todas las [Categoria]s disponibles para el dropdown.
  final List<Categoria> categorias;
  /// Indica si la lista de [categorias] aún se está cargando.
  final bool isLoadingCategories;
  /// Callback que se ejecuta al cambiar la categoría.
  final Function(int?) onCategoriaChanged;
  /// El ID específico de la categoría "Otro".
  final int otroCategoriaId;
  /// Controlador para el campo condicional 'Especifica la categoría'.
  final TextEditingController categoriaSugeridaController;
  /// Flag para ajustar la lógica (actualmente no se usa, pero está disponible).
  final bool isEditing;

  /// {@macro seccion_detalles_principales}
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
    /// Determina si el campo de sugerencia debe mostrarse.
    final bool mostrarSugerencia = categoriaSeleccionada == otroCategoriaId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Campo Título (Requerido).
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

        /// Campo Urgencia (Requerido).
        DropdownButtonFormField<String>(
          value: urgenciaSeleccionada,
          decoration: const InputDecoration(
            labelText: 'Nivel de Urgencia *',
            border: OutlineInputBorder(),
          ),
          items: ['Baja', 'Media', 'Alta']
              .map((label) => DropdownMenuItem(value: label, child: Text(label)))
              .toList(),
          onChanged: (value) => onUrgenciaChanged(value!),
        ),
        const SizedBox(height: 16),

        /// Campo Categoría (Requerido).
        isLoadingCategories
            // Muestra un spinner mientras se cargan las categorías.
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
                    .map((cat) =>
                        DropdownMenuItem(value: cat.id, child: Text(cat.nombre)))
                    .toList(),
                onChanged: onCategoriaChanged,
                validator: (value) =>
                    value == null ? 'Selecciona una categoría' : null,
              ),
        const SizedBox(height: 16),

        /// Campo Sugerir Categoría (Condicional).
        /// Se muestra solo si la categoría seleccionada es "Otro".
        if (mostrarSugerencia)
          TextFormField(
            controller: categoriaSugeridaController,
            decoration: const InputDecoration(
              labelText: 'Especifica la categoría *',
              hintText: 'Ej. Poste caído, Semáforo malogrado',
              border: OutlineInputBorder(),
            ),
            /// Se valida solo si está visible.
            validator: (value) =>
                (mostrarSugerencia && (value == null || value.trim().isEmpty))
                    ? 'Debes sugerir una categoría si eliges "Otro"'
                    : null,
          ),
      ],
    );
  }
}