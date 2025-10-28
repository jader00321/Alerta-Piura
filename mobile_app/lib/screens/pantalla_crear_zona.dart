import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/api/perfil_service.dart';

/// {@template pantalla_crear_zona}
/// Pantalla para crear una nueva Zona Segura (función Premium).
///
/// Permite al usuario seleccionar un punto central en el mapa, ajustar un radio
/// y dar un nombre a la zona antes de guardarla.
/// {@endtemplate}
class PantallaCrearZona extends StatefulWidget {
  /// {@macro pantalla_crear_zona}
  const PantallaCrearZona({super.key});

  @override
  State<PantallaCrearZona> createState() => _PantallaCrearZonaState();
}

/// Estado para [PantallaCrearZona].
///
/// Maneja el [MapController], el estado del formulario (nombre),
/// la posición central, el radio y la lógica de guardado.
class _PantallaCrearZonaState extends State<PantallaCrearZona> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _mapController = MapController();

  /// El punto central actual de la zona que se está creando.
  LatLng _centroZona = const LatLng(-5.19449, -80.63282); // Centro de Piura por defecto
  /// El radio actual en metros de la zona que se está creando.
  double _radioMetros = 500.0; // 500m por defecto
  /// Indica si se está guardando la zona.
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  /// Valida el nombre y guarda la nueva zona segura usando [PerfilService].
  Future<void> _guardarZona() async {
    if (!_formKey.currentState!.validate() || _isLoading) {
      return;
    }

    setState(() => _isLoading = true);

    final success = await PerfilService().crearZonaSegura(
      nombre: _nombreController.text.trim(),
      centro: _centroZona,
      radio: _radioMetros.toInt(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              success ? 'Zona Segura creada con éxito' : 'Error al crear la zona'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        Navigator.pop(context, true); // Devuelve 'true' para indicar éxito
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nueva Zona Segura'),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white))
                : const Icon(Icons.save),
            onPressed: _guardarZona,
            tooltip: 'Guardar Zona',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _centroZona,
                  initialZoom: 15.0,
                  onPositionChanged: (position, hasGesture) {
                    if (hasGesture) {
                      setState(() => _centroZona = position.center);
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.mobile_app',
                  ),
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: _centroZona,
                        radius: _radioMetros,
                        useRadiusInMeter: true,
                        color: Theme.of(context).colorScheme.primary.withAlpha(51),
                        borderColor: Theme.of(context).colorScheme.primary,
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
                  const Center(
                    child: Icon(Icons.location_pin, size: 50, color: Colors.red),
                  ),
                ],
              ),
            ),
            Card(
              margin: EdgeInsets.zero,
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la Zona (ej. "Casa", "Oficina")',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          (value?.isEmpty ?? true) ? 'El nombre es requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    Text('Radio de la zona: ${_radioMetros.toInt()} metros'),
                    Slider(
                      value: _radioMetros,
                      min: 100, // Radio mínimo de 100m
                      max: 2000, // Radio máximo de 2km
                      divisions: 19,
                      label: '${_radioMetros.toInt()}m',
                      onChanged: (value) {
                        setState(() => _radioMetros = value);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}