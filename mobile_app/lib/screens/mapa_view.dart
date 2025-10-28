import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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

/// Vista principal de la aplicación que muestra el mapa interactivo,
/// los reportes, el indicador de riesgo y las acciones principales (Filtros, SOS, etc.).
class MapaView extends StatefulWidget {
  const MapaView({super.key});

  @override
  State<MapaView> createState() => _MapaViewState();
}

/// Estado para [MapaView].
///
/// Maneja la carga de reportes, filtros, cálculo de riesgo,
/// estado de SOS y la interacción del usuario con el mapa.
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

  int? _activeAlertId;
  bool _isSosActive = false;
  int _sosRemainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadReportes();

    FlutterBackgroundService().on('update').listen((event) {
      if (!mounted || event == null) return;
      final action = event['action'] as String?;
      debugPrint("MAPA_VIEW: Evento recibido del servicio: $action, Data: $event");

      if (!mounted) return;

      switch (action) {
        case 'currentSosStatus':
          setState(() {
            _isSosActive = event['isActive'] ?? false;
            _activeAlertId = event['alertId'];
            _sosRemainingSeconds = event['seconds'] ?? 0;
            debugPrint("MAPA_VIEW: Estado inicial/actual de SOS recibido -> isActive: $_isSosActive, alertId: $_activeAlertId, remaining: $_sosRemainingSeconds");
          });
          break;
        case 'updateTimer':
          setState(() => _sosRemainingSeconds = event['seconds'] ?? 0);
          break;
        case 'sosStarted':
          setState(() {
            _isSosActive = true;
            _activeAlertId = event['alertId'];
            _sosRemainingSeconds = event['seconds'] ?? 0;
          });
          break;
        case 'sosFinished':
          setState(() {
            _isSosActive = false;
            _activeAlertId = null;
            _sosRemainingSeconds = 0;
          });
          if (event['error'] != null) {
            if (ScaffoldMessenger.maybeOf(context) != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Error en SOS: ${event['error']}'),
                backgroundColor: Colors.red,
              ));
            }
          }
          break;
        case 'connectionLost':
          if (ScaffoldMessenger.maybeOf(context) != null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('SOS: Conexión perdida...'),
                backgroundColor: Colors.orange));
          }
          break;
        default:
          debugPrint("MAPA_VIEW: Evento desconocido recibido del servicio: $action");
      }
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        debugPrint("MAPA_VIEW: Solicitando estado inicial de SOS al servicio...");
        FlutterBackgroundService().invoke('getSosStatus');
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _riesgoDebounce?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  /// Carga los reportes desde [ReporteService] aplicando los filtros actuales.
  void _loadReportes() {
    final String search = _searchQuery;
    final String estado;
    if (_activeFilters.estado == 'Pendiente') {
      estado = 'pendiente_verificacion';
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

  /// Obtiene el puntaje de riesgo para el centro actual del mapa.
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
        setState(() {
          _riesgoScore = score;
          _isLoadingRisk = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching riesgo zona: $e");
      if (mounted) {
        setState(() => _isLoadingRisk = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No se pudo calcular el riesgo de la zona.'),
          backgroundColor: Colors.orange,
        ));
      }
    }
  }

  /// Maneja el cambio de texto en la barra de búsqueda con un debounce.
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 700), () {
      if (mounted && query.trim() != _searchQuery) {
        setState(() {
          _searchQuery = query.trim();
        });
        _loadReportes();
      }
    });
  }

  /// Muestra el modal [PanelFiltrosAvanzados].
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

  /// Muestra el modal [ReportSummarySheet] al tocar un reporte.
  void _showReportSummary(BuildContext context, Reporte reporte) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => ReportSummarySheet(reporte: reporte));
  }

  /// Centra el mapa en la ubicación actual del usuario.
  Future<void> _centerOnUserLocation() async {
    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      status = await Permission.locationWhenInUse.request();
    }

    if (!mounted) return;

    if (status.isGranted) {
      try {
        Position p = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
                timeLimit: Duration(seconds: 10)));
        if (mounted) {
          _mapController.move(LatLng(p.latitude, p.longitude), 16.0);
        }
      } catch (e) {
        debugPrint("Error obteniendo ubicación: $e");
        if (mounted && ScaffoldMessenger.maybeOf(context) != null) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No se pudo obtener la ubicación actual.')));
        }
      }
    } else {
      debugPrint("Permiso de ubicación denegado.");
      if (mounted && ScaffoldMessenger.maybeOf(context) != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Se necesita permiso de ubicación para centrar.')));
      }
    }
  }

  /// Inicia el flujo de activación de SOS contactando al [BackgroundService].
  Future<void> _activateSos() async {
    if (!mounted) return;

    if (_isSosActive) {
      debugPrint("MAPA_VIEW: SOS ya está activo. Mostrando diálogo de desactivación.");
      _deactivateSosFromUI();
      return;
    }

    debugPrint("MAPA_VIEW: Solicitando activación de SOS al servicio...");

    if (ScaffoldMessenger.maybeOf(context) != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Activando Alerta SOS...'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ));
    }

    final prefs = await SharedPreferences.getInstance();
    final durationInMinutes = prefs.getDouble('sosDuration') ?? 10.0;
    final durationInSeconds = durationInMinutes.toInt() * 60;
    final contact = {
      'nombre': prefs.getString('contactNombre'),
      'telefono': prefs.getString('contactTelefono'),
      'mensaje': prefs.getString('contactMensaje'),
    };

    FlutterBackgroundService().invoke('startSosTracking',
        {'durationInSeconds': durationInSeconds, 'emergencyContact': contact});
  }

  /// Muestra un diálogo para confirmar la desactivación de SOS.
  void _deactivateSosFromUI() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finalizar Alerta SOS'),
        content: const Text('¿Estás seguro que deseas finalizar tu alerta?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                debugPrint("MAPA_VIEW: Solicitando detención de SOS al servicio...");
                FlutterBackgroundService().invoke('stopSosFromUI');
                Navigator.pop(ctx);
              },
              child: const Text('Sí, Finalizar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();

    return Scaffold(
      body: Stack(
        children: [
          CapaMapaBase(
            reportesFuture: _reportesFuture,
            mapController: _mapController,
            initialCenter: _initialCenter,
            onMapReady: _fetchRiesgoZona,
            onPositionChanged: (MapEvent event) {
              if (event.source != MapEventSource.mapController &&
                  event.source != MapEventSource.custom) {
                if (_riesgoDebounce?.isActive ?? false) {
                  _riesgoDebounce!.cancel();
                }
                _riesgoDebounce =
                    Timer(const Duration(milliseconds: 750), _fetchRiesgoZona);
              }
            },
            onShowReportSummary: _showReportSummary,
            isHeatmapVisible: false,
          ),
          const PinPulsante(),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TopSearchBar(onSearchChanged: _onSearchChanged),
                  _isLoadingRisk
                      ? Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20)),
                          child: const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white)))
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
        onCreateReport: () {
          if (authNotifier.isAuthenticated) {
            Navigator.pushNamed(context, '/create_report');
          } else {
            Navigator.pushNamed(context, '/login');
          }
        },
        isSosActive: _isSosActive,
        sosRemainingSeconds: _sosRemainingSeconds,
        onActivateSos: _activateSos,
        onDeactivateSos: _deactivateSosFromUI,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}