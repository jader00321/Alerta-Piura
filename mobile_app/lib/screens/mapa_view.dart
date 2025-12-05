import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:mobile_app/models/reporte_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/providers/map_preferences_provider.dart'; // <-- IMPORTANTE
import 'package:mobile_app/widgets/home/top_search_bar.dart';
import 'package:mobile_app/widgets/mapa/panel_filtros_avanzados.dart';
import 'package:mobile_app/widgets/mapa/pin_pulsante.dart';
import 'package:mobile_app/widgets/mapa/indicador_riesgo.dart';
import 'package:mobile_app/widgets/mapa/report_summary_sheet.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/widgets/mapa/capa_mapa_base.dart';
import 'package:mobile_app/widgets/mapa/acciones_mapa.dart';

class MapaView extends StatefulWidget {
  const MapaView({super.key});

  @override
  State<MapaView> createState() => _MapaViewState();
}

class _MapaViewState extends State<MapaView> {
  final ReporteService _reporteService = ReporteService();
  final MapController _mapController = MapController();

  late Future<List<Reporte>> _reportesFuture;
  EstadoFiltros _activeFilters = EstadoFiltros();
  Timer? _debounce;
  Timer? _riesgoDebounce;
  int _riesgoScore = 0;
  bool _isLoadingRisk = true;
  String _searchQuery = '';

  // ignore: unused_field
  int? _activeAlertId;
  bool _isSosActive = false;
  int _sosRemainingSeconds = 0;
  
  // Controla si ya movimos el mapa a la posición inicial guardada
  bool _initialMoveDone = false;

  @override
  void initState() {
    super.initState();
    _loadReportes();
    _setupSosListener();
  }

  // Configuración separada para limpieza del código
  void _setupSosListener() {
    FlutterBackgroundService().on('update').listen((event) {
      if (!mounted || event == null) return;
      final action = event['action'] as String?;
      
      switch (action) {
        case 'currentSosStatus':
        case 'sosStarted':
          setState(() {
            _isSosActive = event['isActive'] ?? (action == 'sosStarted');
            _activeAlertId = event['alertId'];
            _sosRemainingSeconds = event['seconds'] ?? 0;
          });
          break;
        case 'updateTimer':
          if (mounted) setState(() => _sosRemainingSeconds = event['seconds'] ?? 0);
          break;
        case 'sosFinished':
          if (mounted) {
            setState(() {
              _isSosActive = false;
              _activeAlertId = null;
              _sosRemainingSeconds = 0;
            });
            if (event['error'] != null) {
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error SOS: ${event['error']}")));
            }
          }
          break;
      }
    });
    // Pedir estado inicial
    Future.delayed(const Duration(milliseconds: 500), () {
      FlutterBackgroundService().invoke('getSosStatus');
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _riesgoDebounce?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  // --- Lógica de Ubicaciones Guardadas (NUEVO) ---

  /// Muestra un diálogo para guardar la ubicación actual con un nombre.
  void _showSaveLocationDialog() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Guardar Ubicación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ponle un nombre a esta vista para volver a ella fácilmente.'),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nombre (ej. Casa, Trabajo)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final center = _mapController.camera.center;
                // Guardar usando el Provider
                context.read<MapPreferencesProvider>().addLocation(
                  nameController.text.trim(),
                  center.latitude,
                  center.longitude,
                  setAsDefault: true, // La hacemos default automáticamente
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ubicación guardada y establecida como inicio.')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  /// Muestra un menú inferior (Sheet) para cambiar rápidamente de ubicación.
  void _showQuickLocationSwitcher() {
    final mapProvider = context.read<MapPreferencesProvider>();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mis Ubicaciones', style: Theme.of(context).textTheme.titleLarge),
              const Divider(),
              if (mapProvider.ubicaciones.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No tienes ubicaciones guardadas.'),
                ),
              
              // Opción Default del Sistema
              ListTile(
                leading: const Icon(Icons.settings_system_daydream),
                title: const Text('Piura Centro (Sistema)'),
                onTap: () {
                  mapProvider.restoreSystemDefault();
                  _mapController.move(MapPreferencesProvider.sistemaDefaultLocation, 15.0);
                  Navigator.pop(ctx);
                },
              ),

              // Lista de guardadas
              ...mapProvider.ubicaciones.map((loc) => ListTile(
                leading: const Icon(Icons.place, color: Colors.teal),
                title: Text(loc.nombre),
                selected: mapProvider.defaultLocationId == loc.id,
                onTap: () {
                  mapProvider.setDefaultLocation(loc.id);
                  _mapController.move(loc.toLatLng(), 16.0); // Movemos el mapa
                  Navigator.pop(ctx);
                },
              )),
              
              const Divider(),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, '/gestionar_ubicaciones');
                },
                child: const Text('Gestionar Ubicaciones'),
              )
            ],
          ),
        );
      },
    );
  }

  // --- Fin Lógica Ubicaciones ---

  void _loadReportes() {
    final String search = _searchQuery;
    final String estado = _activeFilters.estado == 'Pendiente' ? 'pendiente_verificacion' : 'verificado';
    const int limit = 100;
    final apiFilters = <String, String>{};
    if (_activeFilters.categoriaId != null) apiFilters['categoriaId'] = _activeFilters.categoriaId.toString();
    if (_activeFilters.rangoFechas == 'Últimos 7 días') apiFilters['dias'] = '7';
    else if (_activeFilters.rangoFechas == 'Últimos 30 días') apiFilters['dias'] = '30';
    
    setState(() {
      _reportesFuture = _reporteService.getAllReports(
        filters: apiFilters.isNotEmpty ? apiFilters : null,
        search: search,
        estado: estado,
        limit: limit,
      );
    });
  }

  // ... (Resto de métodos existentes: _fetchRiesgoZona, _onSearchChanged, _showFilterSheet, etc. mantenlos igual)
  Future<void> _fetchRiesgoZona() async {
    if (!mounted) return;
    setState(() => _isLoadingRisk = true);
    try {
        final center = _mapController.camera.center;
        final score = await _reporteService.getRiesgoZona(center, centerPoint: center, radius: 500);
        if(mounted) setState(() { _riesgoScore = score; _isLoadingRisk = false; });
    } catch (_) { if(mounted) setState(() => _isLoadingRisk = false); }
  }
  
  void _onSearchChanged(String query) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 700), () {
        if (mounted && query.trim() != _searchQuery) {
          setState(() => _searchQuery = query.trim());
          _loadReportes();
        }
      });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PanelFiltrosAvanzados(
        filtrosIniciales: _activeFilters,
        onAplicarFiltros: (newFilters) {
          if (mounted) {
            setState(() => _activeFilters = newFilters);
            _loadReportes();
          }
        },
      ),
    );
  }

  void _showReportSummary(BuildContext context, Reporte reporte) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => ReportSummarySheet(reporte: reporte));
  }
  
  Future<void> _centerOnUserLocation() async {
     var status = await Permission.locationWhenInUse.status;
     if(!status.isGranted) status = await Permission.locationWhenInUse.request();
     if(status.isGranted) {
         try {
             Position p = await Geolocator.getCurrentPosition();
             _mapController.move(LatLng(p.latitude, p.longitude), 16.0);
         } catch(e) { debugPrint("Error GPS: $e"); }
     }
  }

  Future<void> _activateSos() async {
    if (!mounted) return;

    if (_isSosActive) {
      _deactivateSosFromUI();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    // Obtener Token explícitamente
    final String? token = prefs.getString('authToken'); 

    if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: No hay sesión activa para SOS.'))
        );
        return;
    }

    final double durationMinutes = prefs.getDouble('sosDuration') ?? 10.0;
    final int durationSeconds = (durationMinutes * 60).toInt();
    
    final String? contactName = prefs.getString('contactNombre');
    final String? contactPhone = prefs.getString('contactTelefono');
    final String? contactMsg = prefs.getString('contactMensaje');

    final contact = {
      'nombre': contactName,
      'telefono': contactPhone,
      'mensaje': contactMsg,
    };

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Activando SOS por ${durationMinutes.toInt()} minutos...'),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 2),
    ));

    // ENVIAR TOKEN EN EL PAYLOAD
    FlutterBackgroundService().invoke('startSosTracking', {
        'token': token, // <--- IMPORTANTE
        'durationInSeconds': durationSeconds, 
        'emergencyContact': contact
    });
  }

  void _deactivateSosFromUI() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Finalizar Emergencia?'),
        content: const Text('Se detendrá el rastreo y la transmisión de ubicación.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              FlutterBackgroundService().invoke('stopSosFromUI');
              Navigator.pop(ctx);
            }, 
            child: const Text('Finalizar')
          ),
        ],
      ),
    );
  }

  void _openSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();
    final mapProvider = context.watch<MapPreferencesProvider>();
    final startLocation = mapProvider.activeLocation;

    return Scaffold(
      body: Stack(
        children: [
          CapaMapaBase(
            reportesFuture: _reportesFuture,
            mapController: _mapController,
            initialCenter: startLocation, 
            onMapReady: () {
              // Opcional: Asegurar que se mueva si cambió la preferencia mientras el mapa estaba vivo
              if (!_initialMoveDone) {
                  _fetchRiesgoZona();
                  _initialMoveDone = true;
              }
            },
            onPositionChanged: (MapEvent event) {
              if (event.source != MapEventSource.mapController &&
                  event.source != MapEventSource.custom) {
                if (_riesgoDebounce?.isActive ?? false) _riesgoDebounce!.cancel();
                _riesgoDebounce = Timer(const Duration(milliseconds: 750), _fetchRiesgoZona);
              }
            },
            onShowReportSummary: _showReportSummary,
            isHeatmapVisible: false,
          ),
          const PinPulsante(),
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TopSearchBar(onSearchChanged: _onSearchChanged),
                  _isLoadingRisk
                      ? Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                          child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
                      : Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: IndicadorRiesgo(riesgoScore: _riesgoScore),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AccionesMapa(
        onShowFilterSheet: _showFilterSheet,
        onCenterOnUser: _centerOnUserLocation,
        onSetDefaultLocation: _showSaveLocationDialog, 
        onLongPressDefaultLocation: _showQuickLocationSwitcher,
        onCreateReport: () {
          if (authNotifier.isAuthenticated) Navigator.pushNamed(context, '/create_report');
          else Navigator.pushNamed(context, '/login');
        },
        
        // PARAMETROS NUEVOS PARA CONFIGURACION Y SOS
        onOpenSettings: _openSettings, // <-- CONECTADO
        isSosActive: _isSosActive,
        sosRemainingSeconds: _sosRemainingSeconds,
        onActivateSos: _activateSos, // <-- CONECTADO (Con lógica de tiempo)
        onDeactivateSos: _deactivateSosFromUI,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}