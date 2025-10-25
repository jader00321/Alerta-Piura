// lib/widgets/mapa/panel_filtros_avanzados.dart

import 'package:flutter/material.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:mobile_app/models/categoria_model.dart';

class EstadoFiltros {
  String? estado;
  String? rangoFechas;
  int? categoriaId;

  EstadoFiltros({this.estado, this.rangoFechas, this.categoriaId});
}

class PanelFiltrosAvanzados extends StatefulWidget {
  final EstadoFiltros filtrosIniciales;
  final Function(EstadoFiltros) onAplicarFiltros;

  const PanelFiltrosAvanzados({
    super.key,
    required this.filtrosIniciales,
    required this.onAplicarFiltros,
  });

  @override
  State<PanelFiltrosAvanzados> createState() => _PanelFiltrosAvanzadosState();
}

class _PanelFiltrosAvanzadosState extends State<PanelFiltrosAvanzados> {
  late EstadoFiltros _filtrosSeleccionados;
  late Future<List<Categoria>> _categoriasFuture;

  @override
  void initState() {
    super.initState();
    _filtrosSeleccionados = widget.filtrosIniciales;
    _categoriasFuture = ReporteService().getCategorias();
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0, left: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5, // Start at 50% of the screen height
      minChildSize: 0.3,   // Can be dragged down to 30%
      maxChildSize: 0.8,   // Can be dragged up to 80%
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle and Apply Button (fixed at the top)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filtros Avanzados',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text('Aplicar'),
                          onPressed: () {
                            widget.onAplicarFiltros(_filtrosSeleccionados);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Scrollable filter options
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    _buildSectionHeader('Estado del Reporte'),
                    Wrap(
                      spacing: 8.0,
                      children: ['Todos', 'Verificado', 'Pendiente'].map((status) {
                        return ChoiceChip(
                          label: Text(status),
                          selected: _filtrosSeleccionados.estado == status,
                          onSelected: (selected) {
                            setState(() => _filtrosSeleccionados.estado = selected ? status : null);
                          },
                        );
                      }).toList(),
                    ),
                    _buildSectionHeader('Rango de Fechas'),
                    Wrap(
                      spacing: 8.0,
                      children: ['Cualquier fecha', 'Últimos 7 días', 'Últimos 30 días'].map((range) {
                        return ChoiceChip(
                          label: Text(range),
                          selected: _filtrosSeleccionados.rangoFechas == range,
                          onSelected: (selected) {
                            setState(() => _filtrosSeleccionados.rangoFechas = selected ? range : null);
                          },
                        );
                      }).toList(),
                    ),
                    _buildSectionHeader('Categorías'),
                    FutureBuilder<List<Categoria>>(
                      future: _categoriasFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                        return Wrap(
                          spacing: 8.0,
                          children: snapshot.data!.map((cat) {
                            return FilterChip(
                              label: Text(cat.nombre),
                              selected: _filtrosSeleccionados.categoriaId == cat.id,
                              onSelected: (selected) {
                                setState(() => _filtrosSeleccionados.categoriaId = selected ? cat.id : null);
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 80), // Extra space for FAB
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