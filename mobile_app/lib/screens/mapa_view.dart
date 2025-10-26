// lib/screens/mapa_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // Asegúrate que la importación sea correcta
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

  // Estado SOS
  int? _activeAlertId;
  bool _isSosActive =
      false; // Inicialmente falso hasta que el servicio confirme
  int _sosRemainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadReportes();

    // Listener de eventos del Background Service
    FlutterBackgroundService().on('update').listen((event) {
      if (!mounted || event == null) return; // Chequeo 'mounted'
      final action = event['action'] as String?;
      print("MAPA_VIEW: Evento recibido del servicio: $action, Data: $event");

      // Usar 'mounted' ANTES de setState
      if (!mounted) return;

      switch (action) {
        // Manejar el estado actual al inicio o si se reconecta
        case 'currentSosStatus':
          setState(() {
            _isSosActive = event['isActive'] ?? false;
            _activeAlertId = event['alertId'];
            _sosRemainingSeconds = event['seconds'] ?? 0;
            print(
                "MAPA_VIEW: Estado inicial/actual de SOS recibido -> isActive: $_isSosActive, alertId: $_activeAlertId, remaining: $_sosRemainingSeconds");
          });
          break;
        case 'updateTimer':
          setState(() => _sosRemainingSeconds = event['seconds'] ?? 0);
          break;
        case 'sosStarted':
          setState(() {
            _isSosActive = true; // Confirmar activación
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
          // Opcional: Mostrar SnackBar si hubo error al activar/funcionar
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
              backgroundColor: Colors.orange,
            ));
          }
          break;
        default:
          print("MAPA_VIEW: Evento desconocido recibido del servicio: $action");
      }
    });

    // Consultar estado inicial del servicio
    // Esperar un breve momento para asegurar que el listener esté listo
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        // Verificar antes de invocar
        print("MAPA_VIEW: Solicitando estado inicial de SOS al servicio...");
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

  void _loadReportes() {
    final String search = _searchQuery;
    final String estado;
    if (_activeFilters.estado == 'Pendiente') {
      estado = 'pendiente_verificacion';
    } else if (_activeFilters.estado == 'Verificado' ||
        _activeFilters.estado == 'Todos' ||
        _activeFilters.estado == null) {
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

  Future<void> _fetchRiesgoZona() async {
    if (!mounted) return;
    setState(() => _isLoadingRisk = true);
    final center = _mapController.camera.center;
    try {
      // Usar el radio definido o un default
      final score = await _reporteService.getRiesgoZona(
        center,
        centerPoint:
            center, // Asegúrate que getRiesgoZona use este parámetro si es necesario
        radius: 500.0, // Radio en metros
      );
      if (mounted) {
        // Verificar 'mounted' antes de setState
        setState(() {
          _riesgoScore = score;
          _isLoadingRisk = false;
        });
      }
    } catch (e) {
      print("Error fetching riesgo zona: $e");
      if (mounted) {
        // Verificar 'mounted' antes de setState
        setState(() => _isLoadingRisk = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No se pudo calcular el riesgo de la zona.'),
          backgroundColor: Colors.orange,
        ));
      }
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
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => ReportSummarySheet(reporte: reporte));
  }

  Future<void> _centerOnUserLocation() async {
    // Verificar permisos primero
    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      status = await Permission.locationWhenInUse.request();
    }

    if (!mounted) return; // Verificar después de await

    if (status.isGranted) {
      try {
        Position p = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 10));
        if (mounted) {
          // Verificar de nuevo antes de usar _mapController
          _mapController.move(LatLng(p.latitude, p.longitude), 16.0);
        }
      } catch (e) {
        print("Error obteniendo ubicación: $e");
        if (mounted && ScaffoldMessenger.maybeOf(context) != null) {
          // Verificar antes de SnackBar
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('No se pudo obtener la ubicación actual.')));
        }
      }
    } else {
      print("Permiso de ubicación denegado.");
      if (mounted && ScaffoldMessenger.maybeOf(context) != null) {
        // Verificar antes de SnackBar
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Se necesita permiso de ubicación para centrar.')));
      }
      // Opcional: abrir configuración de la app
      // openAppSettings();
    }
  }

  Future<void> _activateSos() async {
    if (!mounted) return;

    // Verificar si la alerta ya está activa
    if (_isSosActive) {
      // Si está activa, mostrar el diálogo de desactivación en lugar de activar de nuevo
      print(
          "MAPA_VIEW: SOS ya está activo. Mostrando diálogo de desactivación.");
      _deactivateSosFromUI();
      return; // No continuar con la activación
    }

    print("MAPA_VIEW: Solicitando activación de SOS al servicio...");

    // Mostrar feedback inmediato
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
    // La UI se actualizará cuando reciba 'sosStarted'
  }

  void _deactivateSosFromUI() {
    // Usar showDialog de forma segura
    if (!mounted) return;
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Finalizar Alerta SOS'),
              content:
                  const Text('¿Estás seguro que deseas finalizar tu alerta?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar')),
                ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      print(
                          "MAPA_VIEW: Solicitando detención de SOS al servicio...");
                      FlutterBackgroundService().invoke('stopSosFromUI');
                      Navigator.pop(ctx);
                      // La UI se actualizará con 'sosFinished'
                    },
                    child: const Text('Sí, Finalizar')),
              ],
            ));
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
            onMapReady:
                _fetchRiesgoZona, // Llama a fetchRiesgoZona cuando el mapa está listo
            onPositionChanged: (MapEvent event) {
              // Se dispara con CUALQUIER evento del mapa
              // Solo recalcular riesgo si el evento NO fue causado por el controlador (ej. move)
              // y sí por el usuario (gestos)
              if (event.source != MapEventSource.mapController &&
                  event.source != MapEventSource.custom) {
                if (_riesgoDebounce?.isActive ?? false)
                  _riesgoDebounce!.cancel();
                _riesgoDebounce =
                    Timer(const Duration(milliseconds: 750), _fetchRiesgoZona);
              }
            },
            onShowReportSummary: _showReportSummary, isHeatmapVisible: false,
          ),

          const PinPulsante(), // Pin central

          // --- Barra de Búsqueda e Indicador de Riesgo ---
          // Usar Positioned para controlar la ubicación exacta si SafeArea no es suficiente
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              // SafeArea para evitar la barra de estado
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // La columna ocupa el mínimo espacio
                children: [
                  TopSearchBar(onSearchChanged: _onSearchChanged),
                  // Indicador de Riesgo (se muestra debajo de la barra)
                  _isLoadingRisk
                      ? Container(
                          margin: const EdgeInsets.only(
                              top: 8), // Espacio desde la barra
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
                          // Añadir padding si no está cargando
                          padding: const EdgeInsets.only(top: 8.0),
                          child: IndicadorRiesgo(riesgoScore: _riesgoScore),
                        ),
                ],
              ),
            ),
          ),
          // --- Fin Barra de Búsqueda ---
        ],
      ),
      // Botones Flotantes (AccionesMapa)
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
        // Pasar estado y callbacks de SOS
        isSosActive: _isSosActive,
        sosRemainingSeconds: _sosRemainingSeconds,
        onActivateSos: _activateSos,
        onDeactivateSos: _deactivateSosFromUI,
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat, // Centrar botones flotantes
    );
  }
} // Fin _MapaViewState
