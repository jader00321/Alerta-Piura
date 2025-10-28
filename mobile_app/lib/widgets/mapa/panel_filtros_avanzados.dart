import 'package:flutter/material.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:mobile_app/models/categoria_model.dart';

/// {@template estado_filtros}
/// Clase simple que encapsula el estado de los filtros seleccionados
/// en el [PanelFiltrosAvanzados].
/// {@endtemplate}
class EstadoFiltros {
  /// Estado seleccionado (ej. 'Verificado', 'Pendiente', o `null` para todos).
  String? estado;
  /// Rango de fechas seleccionado (ej. 'Últimos 7 días', o `null` para todos).
  String? rangoFechas;
  /// ID de la categoría seleccionada (o `null` para todas).
  int? categoriaId;

  /// {@macro estado_filtros}
  EstadoFiltros({this.estado, this.rangoFechas, this.categoriaId});
}

/// {@template panel_filtros_avanzados}
/// Panel modal inferior ([DraggableScrollableSheet]) que permite al usuario
/// seleccionar filtros avanzados para la vista del [MapaView].
///
/// Carga las categorías de [ReporteService] y permite filtrar por
/// Estado, Rango de Fechas y Categoría.
/// Devuelve el [EstadoFiltros] seleccionado a través del callback [onAplicarFiltros].
/// {@endtemplate}
class PanelFiltrosAvanzados extends StatefulWidget {
  /// El estado de los filtros actualmente aplicados en el [MapaView].
  final EstadoFiltros filtrosIniciales;
  /// Callback que se ejecuta al presionar "Aplicar", devolviendo el nuevo [EstadoFiltros].
  final Function(EstadoFiltros) onAplicarFiltros;

  /// {@macro panel_filtros_avanzados}
  const PanelFiltrosAvanzados({
    super.key,
    required this.filtrosIniciales,
    required this.onAplicarFiltros,
  });

  @override
  State<PanelFiltrosAvanzados> createState() => _PanelFiltrosAvanzadosState();
}

/// Estado para [PanelFiltrosAvanzados].
///
/// Maneja el estado temporal de los filtros seleccionados ([_filtrosSeleccionados])
/// antes de que sean aplicados, y la carga de las categorías.
class _PanelFiltrosAvanzadosState extends State<PanelFiltrosAvanzados> {
  /// Estado local de los filtros, se actualiza al interactuar con los chips.
  late EstadoFiltros _filtrosSeleccionados;
  /// Futuro que contiene la lista de categorías para el filtro.
  late Future<List<Categoria>> _categoriasFuture;

  @override
  void initState() {
    super.initState();
    // Copia los filtros iniciales al estado local.
    _filtrosSeleccionados = widget.filtrosIniciales;
    // Inicia la carga de categorías.
    _categoriasFuture = ReporteService().getCategorias();
  }

  /// Helper para construir un título de sección.
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0, left: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hoja modal deslizable.
    return DraggableScrollableSheet(
      initialChildSize: 0.5, // Tamaño inicial (50% de la pantalla)
      minChildSize: 0.3, // Tamaño mínimo al arrastrar hacia abajo
      maxChildSize: 0.8, // Tamaño máximo al arrastrar hacia arriba
      expand: false,
      builder: (_, scrollController) {
        // Contenido del panel.
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              /// Cabecera del panel con "handle" y botón "Aplicar".
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  children: [
                    // "Handle" visual para indicar que es deslizable.
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
                        // Botón "Aplicar" que cierra el panel y devuelve los filtros.
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
              /// Contenido scrollable con las opciones de filtro.
              Expanded(
                child: ListView(
                  controller: scrollController, // Vincula el scroll del panel.
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    /// Filtro por Estado (ChoiceChip para selección única).
                    _buildSectionHeader('Estado del Reporte'),
                    Wrap(
                      spacing: 8.0,
                      children: ['Verificado', 'Pendiente'].map((status) {
                        return ChoiceChip(
                          label: Text(status),
                          selected: _filtrosSeleccionados.estado == status,
                          onSelected: (selected) {
                            setState(() {
                              _filtrosSeleccionados.estado =
                                  selected ? status : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    /// Filtro por Rango de Fechas (ChoiceChip para selección única).
                    _buildSectionHeader('Rango de Fechas'),
                    Wrap(
                      spacing: 8.0,
                      children: [
                        'Cualquier fecha',
                        'Últimos 7 días',
                        'Últimos 30 días'
                      ].map((range) {
                        return ChoiceChip(
                          label: Text(range),
                          selected: _filtrosSeleccionados.rangoFechas == range,
                          onSelected: (selected) {
                            setState(() {
                              _filtrosSeleccionados.rangoFechas =
                                  selected ? range : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    /// Filtro por Categorías (FilterChip para selección/deselección).
                    _buildSectionHeader('Categorías'),
                    FutureBuilder<List<Categoria>>(
                      future: _categoriasFuture, // Espera a que carguen las categorías.
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return Wrap(
                          spacing: 8.0,
                          children: snapshot.data!.map((cat) {
                            return FilterChip(
                              label: Text(cat.nombre),
                              selected: _filtrosSeleccionados.categoriaId == cat.id,
                              onSelected: (selected) {
                                setState(() {
                                  _filtrosSeleccionados.categoriaId =
                                      selected ? cat.id : null;
                                });
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 80), // Espacio al final
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