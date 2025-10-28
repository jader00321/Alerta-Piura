import 'package:flutter/material.dart';
import 'package:mobile_app/models/categoria_model.dart';
import 'package:mobile_app/widgets/verificacion/lista_reportes_verificacion.dart';

/// {@template filtros_pendientes}
/// Widget que muestra los controles de filtro para la lista de reportes pendientes
/// en la pantalla de verificación del líder ([ListaReportesVerificacion]).
///
/// Permite filtrar por:
/// - Texto (código o título) mediante un [TextField].
/// - Orden (ascendente/descendente) mediante un [IconButton].
/// - Filtros rápidos ([FiltroPendiente]: Todos, Prioritarios, Con Apoyos) mediante [ChoiceChip].
/// - Categoría mediante un [DropdownButton].
/// {@endtemplate}
class FiltrosPendientes extends StatelessWidget {
  /// Controlador para el campo de búsqueda de texto.
  final TextEditingController searchController;
  /// Criterio de ordenación actual ('fecha_asc' o 'fecha_desc').
  final String sortBy;
  /// Callback para cambiar el criterio de ordenación.
  final VoidCallback onSortToggle;
  /// Filtro rápido actualmente seleccionado ([FiltroPendiente]).
  final FiltroPendiente filtroPendiente;
  /// Callback para cambiar el filtro rápido seleccionado.
  final Function(FiltroPendiente) onFiltroPendienteChanged;
  /// Indica si las categorías aún se están cargando.
  final bool isLoadingCategories;
  /// Lista de categorías disponibles para el dropdown.
  final List<Categoria> categoriasDisponibles;
  /// ID de la categoría actualmente seleccionada para filtrar (o `null` para todas).
  final int? filtroCategoriaId;
  /// Callback para cambiar la categoría seleccionada.
  final Function(int?) onCategoriaChanged;

  /// {@macro filtros_pendientes}
  const FiltrosPendientes({
    super.key,
    required this.searchController,
    required this.sortBy,
    required this.onSortToggle,
    required this.filtroPendiente,
    required this.onFiltroPendienteChanged,
    required this.isLoadingCategories,
    required this.categoriasDisponibles,
    this.filtroCategoriaId,
    required this.onCategoriaChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          /// Fila con el campo de búsqueda y el botón de ordenación.
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por código o título...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                    sortBy == 'fecha_asc'
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    size: 20),
                tooltip: sortBy == 'fecha_asc'
                    ? 'Orden: Más antiguos'
                    : 'Orden: Más recientes',
                onPressed: onSortToggle,
              ),
            ],
          ),
          /// Fila con los filtros rápidos y el dropdown de categoría.
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  /// Chips para los filtros rápidos.
                  Wrap(
                    spacing: 8.0,
                    children: FiltroPendiente.values.map((filtro) {
                      String label;
                      Color color;
                      switch (filtro) {
                        case FiltroPendiente.prioritarios:
                          label = 'Prioritarios';
                          color = Colors.amber.shade700;
                          break;
                        case FiltroPendiente.conApoyos:
                          label = 'Con Apoyos';
                          color = Colors.blue.shade700;
                          break;
                        default:
                          label = 'Todos';
                          color = Theme.of(context).colorScheme.primary;
                          break;
                      }
                      return ChoiceChip(
                        label: Text(label, style: const TextStyle(fontSize: 12)),
                        selected: filtroPendiente == filtro,
                        onSelected: (selected) {
                          if (selected) {
                            onFiltroPendienteChanged(filtro);
                          }
                        },
                        visualDensity: VisualDensity.compact,
                        selectedColor: color.withAlpha(26),
                        labelStyle: TextStyle(
                            color: filtroPendiente == filtro ? color : null),
                      );
                    }).toList(),
                  ),
                  const SizedBox(width: 16),
                  /// Dropdown para filtrar por categoría.
                  if (isLoadingCategories)
                    const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2))
                  else if (categoriasDisponibles.isNotEmpty)
                    DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: filtroCategoriaId,
                        hint:
                            const Text('Categoría', style: TextStyle(fontSize: 12)),
                        isDense: true,
                        items: [
                          // Opción para mostrar todas las categorías.
                          const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('Todas',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold))),
                          // Lista de categorías disponibles.
                          ...categoriasDisponibles.map((cat) =>
                              DropdownMenuItem<int?>(
                                  value: cat.id,
                                  child: Text(cat.nombre,
                                      style: const TextStyle(fontSize: 12)))),
                        ],
                        onChanged: onCategoriaChanged,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}