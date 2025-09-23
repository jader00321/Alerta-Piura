import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_app/models/categoria_model.dart';

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
  final ReporteService _reporteService = ReporteService();
  List<Categoria> _categorias = [];
  bool _isLoadingCategories = true;
  String _urgencia = 'Media';
  String _impacto = 'A mi calle';
  TimeOfDay? _horaIncidente;
  String? _distrito;

  final List<String> _distritosDePiura = ['Piura', 'Castilla', 'Veintiséis de Octubre', 'Catacaos', 'Cura Mori', 'El Tallán', 'La Arena', 'La Unión', 'Las Lomas', 'Tambo Grande'];
  final List<String> _recommendedTags = ['peligroso', 'tráfico', 'niños', 'urgente'];

  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

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
    final service = ReporteService();
    final cats = await service.getCategorias();
    if (mounted) {
      setState(() {
        _categorias = cats;
        if (_categorias.isNotEmpty) {
          _selectedCategoria = _categorias.first.id;
        }
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() {
        _imageFile = selectedImage;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      setState(() => _isLoading = true);
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        if (mounted) {
          setState(() {
            _currentLocation = LatLng(position.latitude, position.longitude);
          });
        }
      } catch (e) {
        // Handle error
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      // Handle permission denied
    }
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate() && _currentLocation != null) {
      // Find the ID for the 'Otro' category
      final otroCategoria = _categorias.firstWhere((cat) => cat.nombre.toLowerCase() == 'otro', orElse: () => Categoria(id: -1, nombre: ''));

      if (_selectedCategoria == otroCategoria.id &&
          _categoriaSugeridaController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Por favor, especifica la categoría.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ));
        return;
      }

      setState(() => _isLoading = true);

      bool success = await _reporteService.createReport(
        idCategoria: _selectedCategoria!,
        titulo: _tituloController.text,
        descripcion: _descripcionController.text,
        location: _currentLocation!,
        esAnonimo: _isAnonimo,
        categoriaSugerida:
            _selectedCategoria == otroCategoria.id ? _categoriaSugeridaController.text : null,
        imagePath: _imageFile?.path,
        urgencia: _urgencia,
        horaIncidente: _horaIncidente?.format(context),
        tags: _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        impacto: _impacto,
        referenciaUbicacion: _referenciaController.text.isEmpty ? null : _referenciaController.text,
        distrito: _distrito,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              success ? 'Reporte enviado para verificación' : 'Error al crear reporte'),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ));
        if (success) {
          Navigator.pop(context, true);
        }
      }
    } else if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Por favor, obtén tu ubicación actual'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ));
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horaIncidente ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _horaIncidente = picked;
      });
    }
  }

  void _addTag(String tag) {
    if (_tagsController.text.isEmpty) {
      _tagsController.text = tag;
    } else {
      _tagsController.text = '${_tagsController.text}, $tag';
    }
  }

  @override
  Widget build(BuildContext context) {
    final otroCategoriaId = _categorias.firstWhere((cat) => cat.nombre.toLowerCase() == 'otro', orElse: () => Categoria(id: -1, nombre: '')).id;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Nuevo Reporte')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_imageFile!.path),
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Añadir Foto'),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título del Reporte'),
                validator: (value) =>
                    value!.isEmpty ? 'El título es requerido' : null,
              ),
              const SizedBox(height: 16),
              const Text('Nivel de Urgencia', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const <ButtonSegment<String>>[
                  ButtonSegment<String>(value: 'Baja', label: Text('Baja')),
                  ButtonSegment<String>(value: 'Media', label: Text('Media')),
                  ButtonSegment<String>(value: 'Alta', label: Text('Alta')),
                ],
                selected: {_urgencia},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _urgencia = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              _isLoadingCategories
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : DropdownButtonFormField<int>(
                      initialValue: _selectedCategoria,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      items: _categorias.map((Categoria cat) {
                        return DropdownMenuItem<int>(
                          value: cat.id,
                          child: Text(cat.nombre),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategoria = value);
                      },
                      validator: (value) => value == null ? 'Selecciona una categoría' : null,
                    ),
              if (_selectedCategoria == otroCategoriaId)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: TextFormField(
                    controller: _categoriaSugeridaController,
                    decoration: const InputDecoration(labelText: 'Especifica la categoría'),
                    validator: (value) => value!.isEmpty ? 'Este campo es requerido' : null,
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration:
                    const InputDecoration(labelText: 'Descripción (Opcional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _distrito,
                decoration: const InputDecoration(labelText: 'Distrito'),
                items: _distritosDePiura.map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (newValue) => setState(() => _distrito = newValue),
                validator: (value) => value == null ? 'Selecciona un distrito' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(controller: _referenciaController, decoration: const InputDecoration(labelText: 'Referencia de Ubicación (Opcional)')),

              const SizedBox(height: 18),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Hora del Incidente (Opcional)'),
                subtitle: Text(_horaIncidente?.format(context) ?? 'No seleccionada'),
                trailing: const Icon(Icons.access_time),
                onTap: _selectTime,
              ),

              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _impacto,
                decoration: const InputDecoration(labelText: 'Impacto del Problema'),
                items: ['Solo a mí', 'A mi calle', 'A todo el barrio']
                    .map((label) => DropdownMenuItem(child: Text(label), value: label))
                    .toList(),
                onChanged: (value) => setState(() => _impacto = value!),
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Etiquetas (separadas por coma)',
                  helperText: 'Ayudan a clasificar mejor tu reporte (ej: inundación, poste caído).'
                )
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Wrap(
                  spacing: 8.0,
                  children: _recommendedTags.map((tag) => ActionChip(
                    label: Text(tag),
                    onPressed: () => _addTag(tag),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Publicar como anónimo'),
                value: _isAnonimo,
                onChanged: (bool? value) => setState(() => _isAnonimo = value!),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.my_location),
                label: const Text('Obtener Ubicación Actual'),
                onPressed: _getCurrentLocation,
              ),
              if (_currentLocation != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Ubicación obtenida: ${_currentLocation!.latitude.toStringAsFixed(4)}, ${_currentLocation!.longitude.toStringAsFixed(4)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.green.shade700),
                  ),
                ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitReport,
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Enviar Reporte'),
                    ),
            const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}