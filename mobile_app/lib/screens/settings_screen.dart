import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importamos los nuevos widgets que hemos creado
import 'package:mobile_app/widgets/configuracion/seccion_apariencia.dart';
import 'package:mobile_app/widgets/configuracion/seccion_notificaciones.dart';
import 'package:mobile_app/widgets/configuracion/seccion_sos.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // El estado de la duración del SOS se mantiene en la pantalla principal
  double _sosDurationInMinutes = 10.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // La lógica para cargar y guardar las preferencias permanece aquí
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _sosDurationInMinutes = prefs.getDouble('sosDuration') ?? 10.0;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSosDuration(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sosDuration', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // 1. Usamos el widget para la sección de apariencia
                const SeccionApariencia(),
                const SizedBox(height: 16),

                // 2. Usamos el widget para la sección de notificaciones
                const SeccionNotificaciones(),
                const SizedBox(height: 16),

                // 3. Usamos el widget para la sección de SOS, pasándole el estado y las funciones
                SeccionSOS(
                  sosDurationInMinutes: _sosDurationInMinutes,
                  onDurationChanged: (value) {
                    setState(() {
                      _sosDurationInMinutes = value;
                    });
                  },
                  onDurationChangeEnd: _saveSosDuration,
                ),
              ],
            ),
    );
  }
}