// lib/screens/pantalla_crear_zona.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/api/perfil_service.dart';

class PantallaCrearZona extends StatefulWidget {
  const PantallaCrearZona({super.key});

  @override
  State<PantallaCrearZona> createState() => _PantallaCrearZonaState();
}

class _PantallaCrearZonaState extends State<PantallaCrearZona> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _mapController = MapController();

  LatLng _centroZona = const LatLng(-5.19449, -80.63282); // Centro de Piura por defecto
  double _radioMetros = 500.0; // 500m por defecto
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _guardarZona() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() => _isLoading = true);

    final success = await PerfilService().crearZonaSegura(
      nombre: _nombreController.text.trim(),
      centro: _centroZona,
      radio: _radioMetros.toInt(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Zona Segura creada con éxito' : 'Error al crear la zona'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        Navigator.pop(context, true); // Devuelve 'true' para indicar que se debe refrescar
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
            icon: const Icon(Icons.save),
            onPressed: _guardarZona,
            tooltip: 'Guardar Zona',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Mapa interactivo
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
                  // Círculo que muestra el radio de la zona
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: _centroZona,
                        radius: _radioMetros,
                        useRadiusInMeter: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        borderColor: Theme.of(context).colorScheme.primary,
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
                  // Pin central fijo
                  const Center(
                    child: Icon(Icons.location_pin, size: 50, color: Colors.red),
                  ),
                ],
              ),
            ),
            // Panel inferior para los controles
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
                      validator: (value) => (value?.isEmpty ?? true) ? 'El nombre es requerido' : null,
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