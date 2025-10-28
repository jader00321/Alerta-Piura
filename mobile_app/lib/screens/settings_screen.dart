import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/widgets/configuracion/seccion_apariencia.dart';
import 'package:mobile_app/widgets/configuracion/seccion_notificaciones.dart';
import 'package:mobile_app/widgets/configuracion/seccion_sos.dart';

/// {@template settings_screen}
/// Pantalla de configuración de la aplicación.
///
/// Permite al usuario ajustar preferencias de apariencia (tema),
/// notificaciones y configuraciones específicas de la función SOS
/// (duración y contacto de emergencia).
/// Utiliza [SharedPreferences] para persistir las configuraciones.
/// {@endtemplate}
class SettingsScreen extends StatefulWidget {
  /// {@macro settings_screen}
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

/// Estado para [SettingsScreen].
///
/// Maneja la carga y guardado de las preferencias del usuario,
/// específicamente la duración de la alerta SOS.
class _SettingsScreenState extends State<SettingsScreen> {
  /// Duración seleccionada para la alerta SOS en minutos.
  double _sosDurationInMinutes = 10.0; // Valor por defecto
  /// Indica si se están cargando las configuraciones iniciales.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Carga la duración SOS guardada desde [SharedPreferences].
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        // Lee la duración guardada o usa 10 minutos como default.
        _sosDurationInMinutes = prefs.getDouble('sosDuration') ?? 10.0;
        _isLoading = false;
      });
    }
  }

  /// Guarda la duración SOS seleccionada en [SharedPreferences].
  ///
  /// Se llama al finalizar el ajuste del slider en [SeccionSOS].
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
                /// Widget para configurar el tema de la aplicación.
                const SeccionApariencia(),
                const SizedBox(height: 16),

                /// Widget para configurar las preferencias de notificación.
                const SeccionNotificaciones(),
                const SizedBox(height: 16),

                /// Widget para configurar la duración SOS y el contacto.
                SeccionSOS(
                  sosDurationInMinutes: _sosDurationInMinutes,
                  onDurationChanged: (value) {
                    // Actualiza el estado local mientras se desliza
                    setState(() {
                      _sosDurationInMinutes = value;
                    });
                  },
                  onDurationChangeEnd: _saveSosDuration, // Guarda al soltar
                ),
              ],
            ),
    );
  }
}