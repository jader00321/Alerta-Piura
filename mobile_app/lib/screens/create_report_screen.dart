import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_app/models/categoria_model.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/widgets/crear_reporte/seccion_evidencia.dart';
import 'package:mobile_app/widgets/crear_reporte/seccion_detalles_principales.dart';
import 'package:mobile_app/widgets/crear_reporte/seccion_detalles_adicionales.dart';
import 'package:mobile_app/widgets/crear_reporte/seccion_acciones_finales.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _categoriaSugeridaController = TextEditingController();
  final _tagsController = TextEditingController();
  final _referenciaController = TextEditingController();

  int? _selectedCategoria;
  bool _isAnonimo = false;
  LatLng? _currentLocation;
  bool _isLoading = false;
  List<Categoria> _categorias = [];
  bool _isLoadingCategories = true;
  String _urgencia = 'Media';
  String _impacto = 'A mi calle';
  TimeOfDay? _horaIncidente;
  String? _distrito;
  XFile? _imageFile;

  final ReporteService _reporteService = ReporteService();
  final ImagePicker _picker = ImagePicker();
  final List<String> _distritosDePiura = [
    'Piura',
    'Castilla',
    'Veintiséis de Octubre',
    'Catacaos',
    'Cura Mori',
    'El Tallán',
    'La Arena',
    'La Unión',
    'Las Lomas',
    'Tambo Grande'
  ];
  final List<String> _recommendedTags = [
    'peligroso',
    'tráfico',
    'niños',
    'urgente'
  ];

  @override
  void initState() {
    super.initState();
    _horaIncidente = TimeOfDay.now();
    _fetchCategories();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _categoriaSugeridaController.dispose();
    _tagsController.dispose();
    _referenciaController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final cats = await _reporteService.getCategorias();
      if (mounted) {
        setState(() {
          _categorias = cats;
          if (_categorias.isNotEmpty) {
            _selectedCategoria = _categorias.first.id;
          }
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al cargar categorías')));
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? selectedImage =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (selectedImage != null) {
      setState(() => _imageFile = selectedImage);
    }
  }

  Future<void> _getCurrentLocation() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      setState(() => _isLoading = true);
      try {
        Position position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
                timeLimit: Duration(seconds: 15)));
        if (mounted) {
          setState(() =>
              _currentLocation = LatLng(position.latitude, position.longitude));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('No se pudo obtener la ubicación.')));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Se necesita permiso de ubicación.')));
      }
    }
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate() && _currentLocation != null) {
      final otroCategoria = _categorias.firstWhere(
          (cat) => cat.nombre.toLowerCase() == 'otro',
          orElse: () => Categoria(id: -1, nombre: ''));
      if (_selectedCategoria == otroCategoria.id &&
          _categoriaSugeridaController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Por favor, especifica la categoría.')));
        return;
      }

      setState(() => _isLoading = true);

      bool success = await _reporteService.createReport(
        idCategoria: _selectedCategoria!,
        titulo: _tituloController.text,
        descripcion: _descripcionController.text,
        location: _currentLocation!,
        esAnonimo: _isAnonimo,
        categoriaSugerida: _selectedCategoria == otroCategoria.id
            ? _categoriaSugeridaController.text
            : null,
        imagePath: _imageFile?.path,
        urgencia: _urgencia,
        horaIncidente: _horaIncidente?.format(context),
        tags: _tagsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        impacto: _impacto,
        referenciaUbicacion: _referenciaController.text.isEmpty
            ? null
            : _referenciaController.text,
        distrito: _distrito,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success
              ? 'Reporte enviado para verificación'
              : 'Error al crear reporte'),
          backgroundColor: success ? Colors.green : Colors.red,
        ));
        if (success) {
          Navigator.pop(context, true);
        }
      }
    } else if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Por favor, obtén tu ubicación actual')));
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horaIncidente ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _horaIncidente = picked);
    }
  }

  void _addTag(String tag) {
    final currentTags =
        _tagsController.text.split(',').map((t) => t.trim()).toList();
    if (!currentTags.contains(tag)) {
      _tagsController.text =
          _tagsController.text.isEmpty ? tag : '${_tagsController.text}, $tag';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();
    final otroCategoriaId = _categorias
        .firstWhere((cat) => cat.nombre.toLowerCase() == 'otro',
            orElse: () => Categoria(id: -1, nombre: ''))
        .id;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Nuevo Reporte')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (authNotifier.isPremium)
                Card(
                  color: const Color.fromARGB(255, 204, 154, 3),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const Icon(Icons.star_border,
                            color: Color.fromARGB(255, 224, 127, 0)),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Como usuario Premium, tu reporte tendrá prioridad visual.',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              SeccionEvidencia(
                imageFile: _imageFile,
                onPickImage: _pickImage,
              ),
              const SizedBox(height: 16),
              SeccionDetallesPrincipales(
                tituloController: _tituloController,
                urgenciaSeleccionada: _urgencia,
                onUrgenciaChanged: (value) => setState(() => _urgencia = value),
                categoriaSeleccionada: _selectedCategoria,
                categorias: _categorias,
                isLoadingCategories: _isLoadingCategories,
                onCategoriaChanged: (value) =>
                    setState(() => _selectedCategoria = value),
                otroCategoriaId: otroCategoriaId,
                categoriaSugeridaController: _categoriaSugeridaController,
              ),
              const SizedBox(height: 16),
              SeccionDetallesAdicionales(
                descripcionController: _descripcionController,
                referenciaController: _referenciaController,
                distritoSeleccionado: _distrito,
                distritos: _distritosDePiura,
                onDistritoChanged: (value) => setState(() => _distrito = value),
                horaIncidente: _horaIncidente,
                onSelectTime: _selectTime,
                impactoSeleccionado: _impacto,
                onImpactoChanged: (value) => setState(() => _impacto = value!),
                tagsController: _tagsController,
                recommendedTags: _recommendedTags,
                onAddTag: _addTag,
              ),
              const SizedBox(height: 16),
              SeccionAccionesFinales(
                isAnonimo: _isAnonimo,
                onAnonimoChanged: (value) =>
                    setState(() => _isAnonimo = value!),
                onGetCurrentLocation: _getCurrentLocation,
                currentLocation: _currentLocation,
                isLoading: _isLoading,
                onSubmitReport: _submitReport,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
