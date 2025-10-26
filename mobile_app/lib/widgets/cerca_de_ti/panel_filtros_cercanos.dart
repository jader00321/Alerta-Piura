import 'package:flutter/material.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:mobile_app/models/categoria_model.dart';

class OpcionFecha {
  final String etiqueta;
  final int? dias;
  const OpcionFecha(this.etiqueta, this.dias);
}

class PanelFiltrosCercanos extends StatefulWidget {
  final FiltrosCercanos filtrosActuales;
  final Function(FiltrosCercanos) onAplicarFiltros;
  final List<Categoria> categoriasDisponibles;

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
    _filtrosSeleccionados = FiltrosCercanos(
      categoriaId: widget.filtrosActuales.categoriaId,
      estado: widget.filtrosActuales.estado,
      urgencia: widget.filtrosActuales.urgencia,
      dias: widget.filtrosActuales.dias,
    );
  }

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
              return FilterChip(
                label: Text(getLabel(item)),
                selected: isSelected(item, currentSelection),
                onSelected: (selected) {
                  setState(() {
                    onSelected(selected ? item : null);
                  });
                },
              );
            } else {
              return ChoiceChip(
                label: Text(getLabel(item)),
                selected: isSelected(item, currentSelection),
                onSelected: (selected) {
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
    final List<Categoria?> categoriasConTodos = [
      null,
      ...widget.categoriasDisponibles
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(26), blurRadius: 10)
              ] // CORREGIDO: withOpacity -> withAlpha
              ),
          child: Column(
            children: [
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
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
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
                    _buildChipSection<Categoria?>(
                        title: 'Categoría',
                        items: categoriasConTodos,
                        currentSelection: categoriasConTodos.firstWhere(
                            (c) => c?.id == _filtrosSeleccionados.categoriaId,
                            orElse: () => null),
                        getLabel: (c) => c?.nombre ?? 'Todas',
                        isSelected: (item, current) => item?.id == current?.id,
                        useFilterChip: true,
                        onSelected: (selectedCategoria) {
                          setState(() {
                            _filtrosSeleccionados = FiltrosCercanos(
                              categoriaId: selectedCategoria?.id,
                              estado: _filtrosSeleccionados.estado,
                              urgencia: _filtrosSeleccionados.urgencia,
                              dias: _filtrosSeleccionados.dias,
                            );
                          });
                        }),
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
                    const SizedBox(height: 30),
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
