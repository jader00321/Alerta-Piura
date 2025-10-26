// lib/widgets/cerca_de_ti/panel_filtros_cercanos.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/api/reporte_service.dart'; // Para FiltrosCercanos
import 'package:mobile_app/models/categoria_model.dart'; // Para Categoria

// Clase simple para manejar las opciones de fecha
class OpcionFecha {
  final String etiqueta;
  final int? dias; // null significa 'Cualquier fecha'
  const OpcionFecha(this.etiqueta, this.dias);
}

class PanelFiltrosCercanos extends StatefulWidget {
  final FiltrosCercanos filtrosActuales;
  final Function(FiltrosCercanos) onAplicarFiltros;
  final List<Categoria>
      categoriasDisponibles; // Pasamos las categorías cargadas

  const PanelFiltrosCercanos({
    super.key,
    required this.filtrosActuales,
    required this.onAplicarFiltros,
    required this.categoriasDisponibles,
  });

  @override
  State<PanelFiltrosCercanos> createState() => _PanelFiltrosCercanosState();
}

class _PanelFiltrosCercanosState extends State<PanelFiltrosCercanos> {
  late FiltrosCercanos _filtrosSeleccionados;

  // Opciones predefinidas con mapeo a valores de API
  final Map<String, String?> _estadosMap = {
    'Todos': null,
    'Verificado': 'verificado',
    'Pendiente': 'pendiente_verificacion',
  };
  final Map<String, String?> _urgenciasMap = {
    'Todas': null,
    'Baja': 'Baja',
    'Media': 'Media',
    'Alta': 'Alta',
  };
  final List<OpcionFecha> _fechas = const [
    OpcionFecha('Cualquier fecha', null),
    OpcionFecha('Últimas 24 horas', 1),
    OpcionFecha('Últimos 7 días', 7),
    OpcionFecha('Últimos 30 días', 30),
  ];

  @override
  void initState() {
    super.initState();
    // Clonamos los filtros iniciales para poder modificarlos
    _filtrosSeleccionados = FiltrosCercanos(
      categoriaId: widget.filtrosActuales.categoriaId,
      estado: widget.filtrosActuales.estado,
      urgencia: widget.filtrosActuales.urgencia,
      dias: widget.filtrosActuales.dias,
    );
  }

  // Helper para construir secciones de Chips
  Widget _buildChipSection<T>({
    required String title,
    required List<T> items,
    required T? currentSelection,
    required Function(T?) onSelected,
    required String Function(T) getLabel,
    required bool Function(T, T?) isSelected,
    bool useFilterChip =
        false, // Flag para usar FilterChip en lugar de ChoiceChip
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
              return FilterChip(
                label: Text(getLabel(item)),
                selected: isSelected(item, currentSelection),
                onSelected: (selected) {
                  setState(() {
                    // FilterChip permite deselección, onSelected pasa true/false
                    onSelected(selected ? item : null);
                  });
                },
              );
            } else {
              return ChoiceChip(
                label: Text(getLabel(item)),
                selected: isSelected(item, currentSelection),
                onSelected: (selected) {
                  // ChoiceChip siempre devuelve true en onSelected
                  // Si el seleccionado es el mismo que el actual, NO lo deseleccionamos (comportamiento estándar)
                  // Simplemente seleccionamos el nuevo item.
                  if (selected) {
                    setState(() {
                      onSelected(item);
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
    // Lista para categorías, incluyendo 'Todas' (representado por null)
    final List<Categoria?> categoriasConTodos = [
      null,
      ...widget.categoriasDisponibles
    ];

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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
              ]),
          child: Column(
            children: [
              // Handle
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
              // Header y Botón Aplicar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filtrar Reportes Cercanos',
                      style: Theme.of(context).textTheme.titleLarge),
                  ElevatedButton(
                    onPressed: () {
                      widget.onAplicarFiltros(_filtrosSeleccionados);
                      Navigator.pop(context);
                    },
                    child: const Text('Aplicar'),
                  ),
                ],
              ),
              const Divider(height: 24),
              // Opciones de Filtro (Scrollable)
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Filtro de Estado
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
                          // ChoiceChip siempre selecciona, no deselecciona
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
                    // Filtro de Categoría (Usando FilterChip)
                    _buildChipSection<Categoria?>(
                        title: 'Categoría',
                        items: categoriasConTodos,
                        currentSelection: categoriasConTodos.firstWhere(
                            (c) => c?.id == _filtrosSeleccionados.categoriaId,
                            orElse: () => null),
                        getLabel: (c) => c?.nombre ?? 'Todas',
                        isSelected: (item, current) => item?.id == current?.id,
                        useFilterChip: true, // Usar FilterChip aquí
                        onSelected: (selectedCategoria) {
                          // onSelected para FilterChip puede dar null si se deselecciona
                          setState(() {
                            _filtrosSeleccionados = FiltrosCercanos(
                              categoriaId: selectedCategoria?.id,
                              estado: _filtrosSeleccionados.estado,
                              urgencia: _filtrosSeleccionados.urgencia,
                              dias: _filtrosSeleccionados.dias,
                            );
                          });
                        }),
                    // Filtro de Urgencia
                    _buildChipSection<String>(
                        title: 'Urgencia',
                        items: _urgenciasMap.keys.toList(),
                        currentSelection: _urgenciasMap.entries
                            .firstWhere(
                                (e) =>
                                    e.value == _filtrosSeleccionados.urgencia,
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
                    // Filtro de Fecha
                    _buildChipSection<OpcionFecha>(
                        title: 'Fecha de Creación',
                        items: _fechas,
                        currentSelection: _fechas.firstWhere(
                            (f) => f.dias == _filtrosSeleccionados.dias,
                            orElse: () => _fechas.first),
                        getLabel: (f) => f.etiqueta,
                        isSelected: (item, current) =>
                            item.dias == current?.dias,
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
                    const SizedBox(
                        height: 30), // Espacio extra al final del scroll
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
