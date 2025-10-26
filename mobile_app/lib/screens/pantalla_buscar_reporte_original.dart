import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:mobile_app/models/reporte_model.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_lista_reportes.dart';

class PantallaBuscarReporteOriginal extends StatefulWidget {
  const PantallaBuscarReporteOriginal({super.key});

  @override
  State<PantallaBuscarReporteOriginal> createState() =>
      _PantallaBuscarReporteOriginalState();
}

class _PantallaBuscarReporteOriginalState
    extends State<PantallaBuscarReporteOriginal> {
  final ReporteService _reporteService = ReporteService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<Reporte> _searchResults = [];
  bool _isLoading = false;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _performSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted && _searchController.text != _searchTerm) {
        _performSearch();
      }
    });
  }

  Future<void> _performSearch() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = true;
      _searchTerm = _searchController.text;
    });

    try {
      final results = await _reporteService.getAllReports(
        search: _searchTerm,
        estado: 'verificado',
        limit: 20,
      );
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error buscando reporte original: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error al buscar: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Reporte Original'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 16),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Buscar por código o título...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withAlpha(
                        128), // CORREGIDO: surfaceVariant -> surfaceContainerHighest, withOpacity -> withAlpha
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const EsqueletoListaReportes()
          : _searchResults.isEmpty
              ? const Center(
                  child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                      'No se encontraron reportes verificados con ese término.',
                      textAlign: TextAlign.center),
                ))
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final reporte = _searchResults[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        title: Text(reporte.titulo,
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Text(reporte.categoria),
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          child: const Icon(Icons.article),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pop(context, reporte.id);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
