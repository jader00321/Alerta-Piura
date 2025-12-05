import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/widgets/configuracion/seccion_apariencia.dart';
import 'package:mobile_app/widgets/configuracion/seccion_notificaciones.dart';
import 'package:mobile_app/widgets/configuracion/seccion_sos.dart';
import 'package:mobile_app/widgets/configuracion/seccion_mapa.dart'; // <-- IMPORTANTE: Asegúrate de tener este archivo

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _sosDurationInMinutes = 10.0;
  bool _isLoading = true;
  
  bool _isSosActive = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _setupSosListener();
  }

  void _setupSosListener() {
    final service = FlutterBackgroundService();
    service.invoke('getSosStatus');
    
    service.on('update').listen((event) {
      if (mounted && event != null) {
        if (event['action'] == 'sosStarted' || event['action'] == 'currentSosStatus') {
          setState(() => _isSosActive = event['isActive'] ?? false);
        }
        if (event['action'] == 'sosFinished') {
          setState(() => _isSosActive = false);
        }
      }
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sosDurationInMinutes = prefs.getDouble('sosDuration') ?? 10.0;
      _isLoading = false;
    });
  }

  Future<void> _saveSosDuration(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sosDuration', value);
  }
  
  void _stopSos() {
    FlutterBackgroundService().invoke('stopSosFromUI');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // --- SECCIÓN 1: APARIENCIA ---
                const SeccionApariencia(),
                const SizedBox(height: 16),

                // --- SECCIÓN 2: MAPA (RESTAURADO) ---
                const SeccionMapa(), 
                const SizedBox(height: 16),

                // --- SECCIÓN 3: NOTIFICACIONES ---
                const SeccionNotificaciones(),
                const SizedBox(height: 16),
                
                // --- SECCIÓN 4: SOS ---
                SeccionSOS(
                  sosDurationInMinutes: _sosDurationInMinutes,
                  onDurationChanged: (value) => setState(() => _sosDurationInMinutes = value),
                  onDurationChangeEnd: _saveSosDuration,
                  isSosActive: _isSosActive, 
                  onStopSos: _stopSos,       
                ),
              ],
            ),
    );
  }
}