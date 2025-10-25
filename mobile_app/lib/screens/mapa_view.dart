// lib/screens/mapa_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:mobile_app/models/reporte_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
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

// --- YA NO SE NECESITA 'with TickerProviderStateMixin' ---
class _MapaViewState extends State<MapaView> {
  final LatLng _initialCenter = const LatLng(-5.19449, -80.63282);
  final ReporteService _reporteService = ReporteService();
  final MapController _mapController = MapController();

  late Future<List<Reporte>> _reportesFuture;
  EstadoFiltros _activeFilters = EstadoFiltros();
  Timer? _debounce;
  Timer? _riesgoDebounce;
  int _riesgoScore = 0;
  bool _isLoadingRisk = true;
  String _searchQuery = '';
  bool _isHeatmapVisible = false;
  Future<List<LatLng>>? _heatmapFuture;

  // --- Estado de SOS Simplificado ---
  int? _activeAlertId; 
  bool _isSosActive = false;
  int _sosRemainingSeconds = 0;
  
  // --- ELIMINADOS ---
  // Timer? _sosHoldTimer;
  // double _sosHoldProgress = 0.0;
  // late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _loadReportes(); // Carga inicial
    
    // --- ELIMINADA LA INICIALIZACIÓN DEL _glowController ---

    FlutterBackgroundService().on('update').listen((event) {
       if (!mounted || event == null) return;
       final action = event['action'] as String?;
       print("MAPA_VIEW: Evento recibido del servicio: $action");
       switch (action) {
         case 'updateTimer':
           if (mounted) setState(() => _sosRemainingSeconds = event['seconds']);
           break;
         case 'sosStarted':
           if (mounted) setState(() { 
             _isSosActive = true; // Asegurarse de que el estado esté sincronizado
             _activeAlertId = event['alertId']; 
             _sosRemainingSeconds = event['seconds']; 
           });
           break;
         case 'sosFinished':
           if (mounted) setState(() { _isSosActive = false; _activeAlertId = null; _sosRemainingSeconds = 0; });
           break;
         case 'connectionLost':
           if (mounted && ScaffoldMessenger.maybeOf(context) != null) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conexión perdida...'), backgroundColor: Colors.orange,));
           }
           break;
       }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _riesgoDebounce?.cancel();
    // --- ELIMINADOS LOS DISPOSE DE TIMERS Y CONTROLADORES DE SOS ---
    _mapController.dispose();
    super.dispose();
  }

  // --- FUNCIÓN _loadReportes (SIN CAMBIOS) ---
  void _loadReportes() {
    final String search = _searchQuery; 
    final String estado;
    if (_activeFilters.estado == 'Pendiente') {
      estado = 'pendiente_verificacion';
    } else if (_activeFilters.estado == 'Verificado' || _activeFilters.estado == 'Todos' || _activeFilters.estado == null) {
      estado = 'verificado'; 
    } else {
       estado = 'verificado';
    }
    const int limit = 100;
    final apiFilters = <String, String>{};
    if (_activeFilters.categoriaId != null) {
      apiFilters['categoriaId'] = _activeFilters.categoriaId.toString();
    }
    if (_activeFilters.rangoFechas == 'Últimos 7 días') {
      apiFilters['dias'] = '7';
    } else if (_activeFilters.rangoFechas == 'Últimos 30 días') {
      apiFilters['dias'] = '30';
    }
    setState(() {
      _reportesFuture = _reporteService.getAllReports(
        filters: apiFilters.isNotEmpty ? apiFilters : null,
        search: search,
        estado: estado,
        limit: limit,
      );
    });
  }
  
  // --- OTRAS FUNCIONES (SIN CAMBIOS) ---
  Future<void> _fetchRiesgoZona() async {
    if (!mounted) return;
    setState(() => _isLoadingRisk = true);
    final center = _mapController.camera.center;
    try {
      final score = await _reporteService.getRiesgoZona(
        center, 
        centerPoint: center,
        radius: 500.0,
      );
      if (mounted) {
          setState(() { _riesgoScore = score; _isLoadingRisk = false; });
      }
    } catch (e) {
        print("Error fetching riesgo zona: $e");
        if (mounted) setState(() => _isLoadingRisk = false);
    }
  }

  void _onSearchChanged(String query) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 700), () {
          if (mounted && query.trim() != _searchQuery) {
            setState(() { 
              _searchQuery = query.trim();
            });
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
        builder: (context) => ReportSummarySheet(reporte: reporte)
      );
  }

  Future<void> _centerOnUserLocation() async {
      final status = await Permission.location.request();
      if (!mounted) return;
      if (status.isGranted) {
          try {
              Position p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, timeLimit: const Duration(seconds: 10));
              if (mounted) _mapController.move(LatLng(p.latitude, p.longitude), 16.0);
          } catch (e) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo obtener la ubicación.')));
          }
      } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Se necesita permiso de ubicación.')));
      }
  }
  
  void _toggleHeatmap() {
      setState(() {
          _isHeatmapVisible = !_isHeatmapVisible;
          if (_isHeatmapVisible && _heatmapFuture == null) {
              _heatmapFuture = _reporteService.getDatosMapaDeCalor();
          }
      });
  }

  // --- ELIMINADAS _onSosPressStart Y _onSosPressEnd ---

  // --- NUEVA FUNCIÓN DE ACTIVACIÓN (LLAMADA POR UN SIMPLE TAP) ---
  Future<void> _activateSos() async {
    if (!mounted) return;

    // 1. Actualización Optimizada de UI
    setState(() {
      _isSosActive = true; 
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Alerta SOS activada.'),
      backgroundColor: Colors.red,
    ));

    // 2. Invocación del Servicio en Segundo Plano
    final prefs = await SharedPreferences.getInstance();
    final durationInMinutes = prefs.getDouble('sosDuration') ?? 10.0;
    final durationInSeconds = durationInMinutes.toInt() * 60;
    final contact = {
      'nombre': prefs.getString('contactNombre'),
      'telefono': prefs.getString('contactTelefono'),
      'mensaje': prefs.getString('contactMensaje'),
    };

    FlutterBackgroundService().invoke('startSosTracking', {
      'durationInSeconds': durationInSeconds,
      'emergencyContact': contact
    });
  }


  // --- FUNCIÓN DE DESACTIVACIÓN (SIN CAMBIOS, SIGUE SIENDO VÁLIDA) ---
  void _deactivateSosFromUI() {
      showDialog(context: context, builder: (ctx) => AlertDialog(
          title: const Text('Finalizar Alerta SOS'),
          content: const Text('¿Estás seguro que deseas finalizar tu alerta?'),
          actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                      FlutterBackgroundService().invoke('stopSosFromUI');
                      Navigator.pop(ctx);
                       // El estado _isSosActive se actualizará desde el listener del servicio
                  },
                  child: const Text('Sí, Finalizar')),
          ],
      ));
  }
  // --- FIN FUNCIONES SOS ---


  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();

    return Scaffold(
      body: Stack(
        children: [
          CapaMapaBase(
            reportesFuture: _reportesFuture,
            heatmapFuture: _heatmapFuture,
            mapController: _mapController,
            initialCenter: _initialCenter,
            onMapReady: _fetchRiesgoZona,
            onPositionChanged: (MapEvent event) {
              if (event.source != MapEventSource.mapController) {
                if (_riesgoDebounce?.isActive ?? false) _riesgoDebounce!.cancel();
                _riesgoDebounce = Timer(const Duration(milliseconds: 750), _fetchRiesgoZona);
              }
            },
            onShowReportSummary: _showReportSummary,
            isHeatmapVisible: _isHeatmapVisible,
          ),

          const PinPulsante(),

          SafeArea(
            child: Column(
              children: [
                TopSearchBar(onSearchChanged: _onSearchChanged),
                Align(
                  alignment: Alignment.topCenter,
                  child: _isLoadingRisk
                      ? Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)), child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
                      : IndicadorRiesgo(riesgoScore: _riesgoScore),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AccionesMapa(
        onToggleHeatmap: _toggleHeatmap,
        isHeatmapVisible: _isHeatmapVisible,
        onShowFilterSheet: _showFilterSheet,
        onCenterOnUser: _centerOnUserLocation,
        onCreateReport: () {
          if (authNotifier.isAuthenticated) {
            Navigator.pushNamed(context, '/create_report');
          } else {
            Navigator.pushNamed(context, '/login');
          }
        },
        // --- PARÁMETROS DE SOS SIMPLIFICADOS ---
        isSosActive: _isSosActive,
        sosRemainingSeconds: _sosRemainingSeconds,
        onActivateSos: _activateSos, // <-- NUEVA FUNCIÓN
        onDeactivateSos: _deactivateSosFromUI,
        // --- ELIMINADOS ---
        // sosHoldProgress: _sosHoldProgress,
        // sosActiveAnimation: _glowController,
        // onSosPressStart: _onSosPressStart,
        // onSosPressEnd: _onSosPressEnd,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}