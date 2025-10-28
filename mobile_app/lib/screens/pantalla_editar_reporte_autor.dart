import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:mobile_app/models/categoria_model.dart';
import 'package:mobile_app/models/reporte_detallado_model.dart';
import 'package:mobile_app/widgets/crear_reporte/seccion_detalles_principales.dart';
import 'package:mobile_app/widgets/crear_reporte/seccion_detalles_adicionales.dart';

/// {@template pantalla_editar_reporte_autor}
/// Pantalla que permite al autor original de un reporte editarlo,
/// siempre y cuando el reporte siga en estado 'pendiente_verificacion'.
///
/// Reutiliza varios widgets de [CreateReportScreen] para los campos del formulario.
/// Recibe el [ReporteDetallado] inicial para pre-llenar los campos.
/// {@endtemplate}
class PantallaEditarReporteAutor extends StatefulWidget {
  /// Los datos iniciales del reporte a editar.
  final ReporteDetallado reporteInicial;

  /// {@macro pantalla_editar_reporte_autor}
  const PantallaEditarReporteAutor({super.key, required this.reporteInicial});

  @override
  State<PantallaEditarReporteAutor> createState() =>
      _PantallaEditarReporteAutorState();
}

/// Estado para [PantallaEditarReporteAutor].
///
/// Maneja los controladores del formulario, carga las categorías disponibles,
/// y envía los datos actualizados a [ReporteService.editarReporteAutor].
class _PantallaEditarReporteAutorState
    extends State<PantallaEditarReporteAutor> {
  final _formKey = GlobalKey<FormState>();
  final ReporteService _reporteService = ReporteService();

  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late TextEditingController _referenciaController;
  late TextEditingController _tagsController;
  late TextEditingController _categoriaSugeridaController;

  int? _selectedCategoriaId;
  String _urgencia = 'Media';
  String _impacto = 'A mi calle';
  TimeOfDay? _horaIncidente;
  String? _distrito;
  List<Categoria> _categoriasDisponibles = [];
  bool _isLoading = false;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.reporteInicial.titulo);
    _descripcionController =
        TextEditingController(text: widget.reporteInicial.descripcion);
    _referenciaController =
        TextEditingController(text: widget.reporteInicial.referenciaUbicacion);
    _tagsController = TextEditingController(text: widget.reporteInicial.tags.join(', '));
    // Inicialmente vacío, se llena si 'Otro' está seleccionado y ya había sugerencia.
    _categoriaSugeridaController = TextEditingController();

    _urgencia = widget.reporteInicial.urgencia ?? 'Media';
    _impacto = widget.reporteInicial.impacto ?? 'A mi calle';
    _distrito = widget.reporteInicial.distrito;

    if (widget.reporteInicial.horaIncidente != null) {
      try {
        final format = DateFormat.Hm(); // Formato HH:mm
        final dt = format.parse(widget.reporteInicial.horaIncidente!);
        _horaIncidente = TimeOfDay.fromDateTime(dt);
      } catch (e) {
        debugPrint("Error parseando hora inicial: $e");
        _horaIncidente = TimeOfDay.now();
      }
    } else {
      _horaIncidente = TimeOfDay.now();
    }

    _loadCategoriesAndSetInitial();
  }

  /// Carga las categorías desde la API y establece la categoría inicial del reporte.
  Future<void> _loadCategoriesAndSetInitial() async {
    setState(() => _isLoadingCategories = true);
    try {
      final cats = await _reporteService.getCategorias();
      if (mounted) {
        int? initialCatId;
        String initialSuggestedCategory = '';
        try {
          final initialCat =
              cats.firstWhere((c) => c.nombre == widget.reporteInicial.categoria);
          initialCatId = initialCat.id;
          // Si la categoría inicial es 'Otro', pre-llenar la sugerencia si existe
          if (initialCat.nombre.toLowerCase() == 'otro' && mounted) {
             // Asumiendo que el modelo detallado tuviera categoria_sugerida
             // initialSuggestedCategory = widget.reporteInicial.categoriaSugerida ?? '';
          }
        } catch (e) {
          initialCatId = null;
          debugPrint("Categoría inicial no encontrada: ${widget.reporteInicial.categoria}");
        }

        setState(() {
          _categoriasDisponibles = cats;
          _selectedCategoriaId = initialCatId;
          _categoriaSugeridaController.text = initialSuggestedCategory;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
      debugPrint("Error cargando categorías: $e");
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _referenciaController.dispose();
    _tagsController.dispose();
    _categoriaSugeridaController.dispose();
    super.dispose();
  }

  /// Valida el formulario y envía los datos actualizados del reporte a la API.
  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate() ||
        _isLoading ||
        _isLoadingCategories ||
        _selectedCategoriaId == null) {
      return;
    }

    final otroCategoria = _categoriasDisponibles.firstWhere(
        (cat) => cat.nombre.toLowerCase() == 'otro',
        orElse: () => Categoria(id: -1, nombre: ''));
    if (_selectedCategoriaId == otroCategoria.id &&
        _categoriaSugeridaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Si eliges "Otro", debes sugerir una categoría.')));
      return;
    }

    setState(() => _isLoading = true);

    List<String> tagsList = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    try {
      final response = await _reporteService.editarReporteAutor(
        widget.reporteInicial.id,
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        idCategoria: _selectedCategoriaId!,
        referenciaUbicacion: _referenciaController.text.trim().isEmpty
            ? null
            : _referenciaController.text.trim(),
        tags: tagsList.isEmpty ? null : tagsList,
        urgencia: _urgencia,
        horaIncidente: _horaIncidente?.format(context),
        impacto: _impacto,
        distrito: _distrito,
      );

      if (!mounted) return;

      final message = response['message'] ?? 'Error desconocido';
      final success = response['statusCode'] == 200;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ));

      if (success) {
        Navigator.pop(context, true); // Devuelve true para indicar éxito
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

  /// Muestra el selector de hora para [horaIncidente].
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horaIncidente ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _horaIncidente) {
      setState(() => _horaIncidente = picked);
    }
  }

  /// Añade una etiqueta recomendada al campo de texto de tags.
  void _addTag(String tag) {
    final currentTags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (!currentTags.contains(tag)) {
      _tagsController.text =
          _tagsController.text.isEmpty ? tag : '${_tagsController.text}, $tag';
    }
  }

  @override
  Widget build(BuildContext context) {
    final otroCategoriaId = _categoriasDisponibles
        .firstWhere((cat) => cat.nombre.toLowerCase() == 'otro',
            orElse: () => Categoria(id: -1, nombre: ''))
        .id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Mi Reporte'),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white))
                : const Icon(Icons.save_outlined),
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
                    SeccionDetallesPrincipales(
                      tituloController: _tituloController,
                      urgenciaSeleccionada: _urgencia,
                      onUrgenciaChanged: (value) =>
                          setState(() => _urgencia = value),
                      categoriaSeleccionada: _selectedCategoriaId,
                      categorias: _categoriasDisponibles,
                      isLoadingCategories: _isLoadingCategories,
                      onCategoriaChanged: (value) =>
                          setState(() => _selectedCategoriaId = value),
                      otroCategoriaId: otroCategoriaId,
                      categoriaSugeridaController: _categoriaSugeridaController,
                      isEditing: true, // Indica que estamos editando
                    ),
                    const SizedBox(height: 16),
                    SeccionDetallesAdicionales(
                      descripcionController: _descripcionController,
                      referenciaController: _referenciaController,
                      distritoSeleccionado: _distrito,
                      distritos: const [
                        'Piura', 'Castilla', 'Veintiséis de Octubre', 'Catacaos',
                        'Cura Mori', 'El Tallán', 'La Arena', 'La Unión',
                        'Las Lomas', 'Tambo Grande'
                      ],
                      onDistritoChanged: (value) =>
                          setState(() => _distrito = value),
                      horaIncidente: _horaIncidente,
                      onSelectTime: _selectTime,
                      impactoSeleccionado: _impacto,
                      onImpactoChanged: (value) =>
                          setState(() => _impacto = value!),
                      tagsController: _tagsController,
                      recommendedTags: const [
                        'peligroso', 'tráfico', 'niños', 'urgente'
                      ],
                      onAddTag: _addTag,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _guardarCambios,
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white))
                          : const Text('Guardar Cambios'),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}