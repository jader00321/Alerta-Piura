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

  int? _selectedCategoria;
  bool _isAnonimo = false;
  LatLng? _currentLocation;
  bool _isLoading = false;
  final ReporteService _reporteService = ReporteService();
  List<Categoria> _categorias = [];
  bool _isLoadingCategories = true;

  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _categoriaSugeridaController.dispose();
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
    final XFile? selectedImage =
        await _picker.pickImage(source: ImageSource.gallery);
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

  @override
  Widget build(BuildContext context) {
    // Find the ID for the 'Otro' category to use in conditional logic
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
                    height: 150,
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
              const SizedBox(height: 12),
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
                    decoration:
                        const InputDecoration(labelText: 'Especifica la categoría'),
                    validator: (value) =>
                        value!.isEmpty ? 'Este campo es requerido' : null,
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcionController,
                decoration:
                    const InputDecoration(labelText: 'Descripción (Opcional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text('Publicar como anónimo'),
                value: _isAnonimo,
                onChanged: (bool? value) {
                  setState(() {
                    _isAnonimo = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 20),
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
                    )
            ],
          ),
        ),
      ),
    );
  }
}