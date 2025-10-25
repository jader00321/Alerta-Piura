// lib/widgets/verificacion/filtros_pendientes.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/models/categoria_model.dart';
import 'package:mobile_app/widgets/verificacion/lista_reportes_verificacion.dart'; // Importa el enum

class FiltrosPendientes extends StatelessWidget {
  final TextEditingController searchController;
  final String sortBy;
  final VoidCallback onSortToggle;
  final FiltroPendiente filtroPendiente;
  final Function(FiltroPendiente) onFiltroPendienteChanged;
  final bool isLoadingCategories;
  final List<Categoria> categoriasDisponibles;
  final int? filtroCategoriaId;
  final Function(int?) onCategoriaChanged;

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
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por título o código...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(sortBy == 'fecha_asc' ? Icons.arrow_upward : Icons.arrow_downward),
                tooltip: sortBy == 'fecha_asc' ? 'Ordenar por más reciente' : 'Ordenar por más antiguo',
                onPressed: onSortToggle,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 35,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Wrap(
                    spacing: 8.0,
                    children: FiltroPendiente.values.map((filtro) {
                      String label; Icon? icon; Color? color;
                      switch(filtro) {
                        case FiltroPendiente.prioritarios: label = 'Premium'; icon = const Icon(Icons.star, size: 14); color = Colors.amber.shade700; break;
                        case FiltroPendiente.conApoyos: label = 'Con Apoyos'; icon = const Icon(Icons.local_fire_department, size: 14); color = Colors.red.shade700; break;
                        default: label = 'Todos'; icon = null; color = Theme.of(context).colorScheme.primary; break;
                      }
                      return ChoiceChip(
                        avatar: icon,
                        label: Text(label, style: const TextStyle(fontSize: 12)),
                        selected: filtroPendiente == filtro,
                        onSelected: (selected) {
                          if (selected) onFiltroPendienteChanged(filtro);
                        },
                        visualDensity: VisualDensity.compact,
                        selectedColor: color.withOpacity(0.1),
                        labelStyle: TextStyle(color: filtroPendiente == filtro ? color : null),
                      );
                    }).toList(),
                  ),
                  const SizedBox(width: 16),
                  if (isLoadingCategories)
                    const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  else if (categoriasDisponibles.isNotEmpty)
                    DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: filtroCategoriaId,
                        hint: const Text('Categoría', style: TextStyle(fontSize: 12)),
                        isDense: true,
                        items: [
                           const DropdownMenuItem<int?>(value: null, child: Text('Todas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                          ...categoriasDisponibles.map((cat) => DropdownMenuItem<int?>(value: cat.id, child: Text(cat.nombre, style: const TextStyle(fontSize: 12)))),
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