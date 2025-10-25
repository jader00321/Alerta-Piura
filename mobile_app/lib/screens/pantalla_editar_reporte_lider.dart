// lib/screens/pantalla_editar_reporte_lider.dart (NUEVO ARCHIVO)
import 'package:flutter/material.dart';
import 'package:mobile_app/api/lider_service.dart';
import 'package:mobile_app/api/reporte_service.dart'; // Para cargar categorías
import 'package:mobile_app/models/categoria_model.dart';
import 'package:mobile_app/models/reporte_detallado_model.dart'; // Para datos iniciales

class PantallaEditarReporteLider extends StatefulWidget {
  final ReporteDetallado reporteInicial;

  const PantallaEditarReporteLider({super.key, required this.reporteInicial});

  @override
  State<PantallaEditarReporteLider> createState() => _PantallaEditarReporteLiderState();
}

class _PantallaEditarReporteLiderState extends State<PantallaEditarReporteLider> {
  final _formKey = GlobalKey<FormState>();
  final LiderService _liderService = LiderService();
  final ReporteService _reporteService = ReporteService();

  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late TextEditingController _referenciaController;
  late TextEditingController _tagsController;
  int? _selectedCategoriaId;
  bool _isLoading = false;
  List<Categoria> _categoriasDisponibles = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.reporteInicial.titulo);
    _descripcionController = TextEditingController(text: widget.reporteInicial.descripcion);
    _referenciaController = TextEditingController(text: widget.reporteInicial.referenciaUbicacion);
    _tagsController = TextEditingController(text: widget.reporteInicial.tags.join(', '));
    _loadCategoriesAndSetInitial();
  }

  Future<void> _loadCategoriesAndSetInitial() async {
    setState(() => _isLoadingCategories = true);
    try {
      final cats = await _reporteService.getCategorias();
      if (mounted) {
        int? initialCatId;
        try {
           initialCatId = cats.firstWhere((c) => c.nombre == widget.reporteInicial.categoria).id;
        } catch (e) {
           initialCatId = null;
        }
        
        setState(() {
          _categoriasDisponibles = cats;
          _selectedCategoriaId = initialCatId;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingCategories = false);
      print("Error cargando categorías: $e");
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _referenciaController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate() || _isLoading || _isLoadingCategories) return;

    setState(() => _isLoading = true);

    List<String> tagsList = _tagsController.text.split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    try {
      final response = await _liderService.editarReporteLider(
        widget.reporteInicial.id,
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        idCategoria: _selectedCategoriaId!,
        referenciaUbicacion: _referenciaController.text.trim(),
        tags: tagsList,
      );

      if (!mounted) return;

      final message = response['message'] ?? 'Error desconocido';
      final success = response['statusCode'] == 200;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ));

      if (success) {
        Navigator.pop(context, true); // Devolver true para indicar éxito
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Reporte'),
        actions: [
          IconButton(
            icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)) : const Icon(Icons.save_outlined),
            onPressed: _guardarCambios,
            tooltip: 'Guardar Cambios',
          )
        ],
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _tituloController,
                      decoration: const InputDecoration(labelText: 'Título del Reporte', border: OutlineInputBorder()),
                      validator: (value) => (value?.trim().isEmpty ?? true) ? 'El título es requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedCategoriaId,
                      decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                      items: _categoriasDisponibles.map((Categoria cat) {
                        return DropdownMenuItem<int>(value: cat.id, child: Text(cat.nombre));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedCategoriaId = value),
                      validator: (value) => value == null ? 'Selecciona una categoría' : null,
                    ),
                     const SizedBox(height: 16),
                    TextFormField(
                      controller: _descripcionController,
                      decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder(), alignLabelWithHint: true),
                      maxLines: 5,
                      minLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _referenciaController,
                      decoration: const InputDecoration(labelText: 'Referencia de Ubicación', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tagsController,
                      decoration: const InputDecoration(labelText: 'Etiquetas (separadas por coma)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _guardarCambios,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _isLoading 
                           ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white)) 
                           : const Text('Guardar Cambios'),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}