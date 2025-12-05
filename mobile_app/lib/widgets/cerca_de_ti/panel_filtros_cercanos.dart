import 'package:flutter/material.dart';
import 'package:mobile_app/api/reporte_service.dart'; // Para FiltrosCercanos
import 'package:mobile_app/models/categoria_model.dart'; // Para Categoria

/// Clase auxiliar simple para definir las opciones del filtro de fecha.
class OpcionFecha {
  /// El texto a mostrar en el chip (ej. "Últimas 24 horas").
  final String etiqueta;
  /// El valor numérico de días a enviar a la API (o `null` para "Cualquier fecha").
  final int? dias;
  const OpcionFecha(this.etiqueta, this.dias);
}

/// {@template panel_filtros_cercanos}
/// Panel modal inferior ([DraggableScrollableSheet]) que permite al usuario
/// seleccionar filtros para la lista de "Reportes Cerca de Ti" ([PantallaCercaDeTi]).
///
/// Gestiona un estado local ([_filtrosSeleccionados]) que se actualiza
/// al interactuar con los chips. Al presionar "Aplicar", devuelve el
/// [FiltrosCercanos] actualizado a la pantalla padre a través de [onAplicarFiltros].
/// {@endtemplate}
class PanelFiltrosCercanos extends StatefulWidget {
  /// El estado de los filtros actualmente aplicados en [PantallaCercaDeTi].
  final FiltrosCercanos filtrosActuales;
  /// Callback que se ejecuta al presionar "Aplicar", devolviendo los nuevos filtros.
  final Function(FiltrosCercanos) onAplicarFiltros;
  /// La lista de categorías (cargada en la pantalla padre) para poblar el filtro.
  final List<Categoria> categoriasDisponibles;

  /// {@macro panel_filtros_cercanos}
  const PanelFiltrosCercanos({
    super.key,
    required this.filtrosActuales,
    required this.onAplicarFiltros,
    required this.categoriasDisponibles,
  });

  @override
  State<PanelFiltrosCercanos> createState() => _PanelFiltrosCercanosState();
}

/// Estado para [PanelFiltrosCercanos].
class _PanelFiltrosCercanosState extends State<PanelFiltrosCercanos> {
  /// Estado local que almacena los filtros seleccionados temporalmente.
  late FiltrosCercanos _filtrosSeleccionados;

  /// Opciones predefinidas para el filtro de Estado y su mapeo a valores de API.
  final Map<String, String?> _estadosMap = {
    'Todos': null,
    'Verificado': 'verificado',
    'Pendiente': 'pendiente_verificacion',
  };
  /// Opciones predefinidas para el filtro de Urgencia y su mapeo a valores de API.
  final Map<String, String?> _urgenciasMap = {
    'Todas': null,
    'Baja': 'Baja',
    'Media': 'Media',
    'Alta': 'Alta',
  };
  /// Opciones predefinidas para el filtro de Fecha.
  final List<OpcionFecha> _fechas = const [
    OpcionFecha('Cualquier fecha', null),
    OpcionFecha('Últimas 24 horas', 1),
    OpcionFecha('Últimos 7 días', 7),
    OpcionFecha('Últimos 30 días', 30),
  ];

  @override
  void initState() {
    super.initState();
    // Clona los filtros actuales de la pantalla padre al estado local del panel.
    _filtrosSeleccionados = FiltrosCercanos(
      categoriaId: widget.filtrosActuales.categoriaId,
      estado: widget.filtrosActuales.estado,
      urgencia: widget.filtrosActuales.urgencia,
      dias: widget.filtrosActuales.dias,
    );
  }

  /// Helper genérico para construir una sección de filtros con [ChoiceChip] o [FilterChip].
  ///
  /// [T]: El tipo de dato de la lista de items (ej. String, Categoria?, OpcionFecha).
  /// [useFilterChip]: Si es `true`, usa [FilterChip] (permite selección múltiple
  /// o deselección). Si es `false` (default), usa [ChoiceChip] (selección única).
  Widget _buildChipSection<T>({
    required String title,
    required List<T> items,
    required T? currentSelection,
    required Function(T?) onSelected,
    required String Function(T) getLabel,
    required bool Function(T, T?) isSelected,
    bool useFilterChip = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: items.map((item) {
            if (useFilterChip) {
              /// [FilterChip] permite deseleccionar (onSelected devuelve `false`).
              return FilterChip(
                label: Text(getLabel(item)),
                selected: isSelected(item, currentSelection),
                onSelected: (selected) {
                  setState(() {
                    onSelected(selected ? item : null); // Pasa null si se deselecciona.
                  });
                },
              );
            } else {
              /// [ChoiceChip] es para selección única (onSelected siempre devuelve `true`).
              return ChoiceChip(
                label: Text(getLabel(item)),
                selected: isSelected(item, currentSelection),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      onSelected(item); // Solo actualiza si se selecciona.
                    });
                  }
                },
              );
            }
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Añade la opción "Todas" (representada por `null`) a la lista de categorías.
    final List<Categoria?> categoriasConTodos = [
      null,
      ...widget.categoriasDisponibles
    ];

    // Hoja modal deslizable.
    return DraggableScrollableSheet(
      initialChildSize: 0.6, // Inicia al 60%
      minChildSize: 0.3, // Mínimo 30%
      maxChildSize: 0.9, // Máximo 90%
      expand: false,
      builder: (_, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(26), blurRadius: 10)
              ]),
          child: Column(
            children: [
              /// "Handle" visual y cabecera con botón "Aplicar".
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filtrar',
                      style: Theme.of(context).textTheme.titleLarge),
                  ElevatedButton(
                    onPressed: () {
                      // Devuelve los filtros seleccionados al padre.
                      widget.onAplicarFiltros(_filtrosSeleccionados);
                      Navigator.pop(context);
                    },
                    child: const Text('Aplicar'),
                  ),
                ],
              ),
              const Divider(height: 24),
              /// Lista scrollable de opciones de filtro.
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    /// Filtro de Estado (Selección Única).
                    _buildChipSection<String>(
                        title: 'Estado',
                        items: _estadosMap.keys.toList(),
                        currentSelection: _estadosMap.entries
                            .firstWhere(
                                (e) => e.value == _filtrosSeleccionados.estado,
                                orElse: () => _estadosMap.entries.first)
                            .key,
                        getLabel: (s) => s,
                        isSelected: (item, current) => item == current,
                        onSelected: (selectedKey) {
                          if (selectedKey != null) {
                            setState(() {
                              _filtrosSeleccionados = FiltrosCercanos(
                                categoriaId: _filtrosSeleccionados.categoriaId,
                                urgencia: _filtrosSeleccionados.urgencia,
                                dias: _filtrosSeleccionados.dias,
                                estado: _estadosMap[selectedKey],
                              );
                            });
                          }
                        }),
                    /// Filtro de Categoría (Selección Única con FilterChip).
                    _buildChipSection<Categoria?>(
                        title: 'Categoría',
                        items: categoriasConTodos,
                        currentSelection: categoriasConTodos.firstWhere(
                            (c) => c?.id == _filtrosSeleccionados.categoriaId,
                            orElse: () => null),
                        getLabel: (c) => c?.nombre ?? 'Todas',
                        isSelected: (item, current) => item?.id == current?.id,
                        useFilterChip: true, // Permite deseleccionar (volver a "Todas")
                        onSelected: (selectedCategoria) {
                          setState(() {
                            _filtrosSeleccionados = FiltrosCercanos(
                              categoriaId: selectedCategoria?.id, // Puede ser null
                              estado: _filtrosSeleccionados.estado,
                              urgencia: _filtrosSeleccionados.urgencia,
                              dias: _filtrosSeleccionados.dias,
                            );
                          });
                        }),
                    /// Filtro de Urgencia (Selección Única).
                    _buildChipSection<String>(
                        title: 'Urgencia',
                        items: _urgenciasMap.keys.toList(),
                        currentSelection: _urgenciasMap.entries
                            .firstWhere(
                                (e) => e.value == _filtrosSeleccionados.urgencia,
                                orElse: () => _urgenciasMap.entries.first)
                            .key,
                        getLabel: (s) => s,
                        isSelected: (item, current) => item == current,
                        onSelected: (selectedKey) {
                          if (selectedKey != null) {
                            setState(() {
                              _filtrosSeleccionados = FiltrosCercanos(
                                categoriaId: _filtrosSeleccionados.categoriaId,
                                estado: _filtrosSeleccionados.estado,
                                urgencia: _urgenciasMap[selectedKey],
                                dias: _filtrosSeleccionados.dias,
                              );
                            });
                          }
                        }),
                    /// Filtro de Fecha (Selección Única).
                    _buildChipSection<OpcionFecha>(
                        title: 'Fecha de Creación',
                        items: _fechas,
                        currentSelection: _fechas.firstWhere(
                            (f) => f.dias == _filtrosSeleccionados.dias,
                            orElse: () => _fechas.first),
                        getLabel: (f) => f.etiqueta,
                        isSelected: (item, current) => item.dias == current?.dias,
                        onSelected: (selectedFecha) {
                          if (selectedFecha != null) {
                            setState(() {
                              _filtrosSeleccionados = FiltrosCercanos(
                                categoriaId: _filtrosSeleccionados.categoriaId,
                                estado: _filtrosSeleccionados.estado,
                                urgencia: _filtrosSeleccionados.urgencia,
                                dias: selectedFecha.dias,
                              );
                            });
                          }
                        }),
                    const SizedBox(height: 30), // Espacio al final del scroll
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}