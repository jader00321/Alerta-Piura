import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/providers/theme_provider.dart';
import 'package:mobile_app/screens/notificaciones_screen.dart'; 
import 'package:mobile_app/screens/editar_contacto_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _sosDurationInMinutes = 10.0; // Default duration
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load saved settings from the device
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Use 10.0 as a default if no value is saved
      _sosDurationInMinutes = prefs.getDouble('sosDuration') ?? 10.0;
      _isLoading = false;
    });
  }

  // Save the new SOS duration to the device
  Future<void> _saveSosDuration(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sosDuration', value);
    setState(() {
      _sosDurationInMinutes = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access the ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración'),),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                // --- Theme Settings ---
                Card(
                  child: SwitchListTile(
                    title: const Text('Modo Oscuro'),
                    subtitle: const Text('Activa o desactiva el tema oscuro.'),
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                    secondary: Icon(
                      themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('Notificaciones'),
                    subtitle: const Text('Ver mensajes y advertencias del sistema.'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificacionesScreen()));
                    },
                  ),
                ),
                // --- SOS Settings ---
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configuración de SOS',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Divider(height: 24),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Duración del seguimiento en vivo'),
                          subtitle: Text(
                            'La app transmitirá tu ubicación por ${_sosDurationInMinutes.toInt()} minutos al activar el SOS.',
                          ),
                        ),
                        Slider(
                          value: _sosDurationInMinutes,
                          min: 5,
                          max: 30,
                          divisions: 5, // 30-5 = 25. 25/5 = 5 minute intervals
                          label: '${_sosDurationInMinutes.toInt()} min',
                          onChanged: (value) {
                            setState(() {
                              _sosDurationInMinutes = value;
                            });
                          },
                          // Save the value only when the user stops sliding
                          onChangeEnd: _saveSosDuration,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.contact_emergency),
                          title: const Text('Contacto de Emergencia'),
                          subtitle: const Text('Añadir un número para notificar.'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const EditarContactoScreen()));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}