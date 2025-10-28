import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:mobile_app/models/reporte_cercano_model.dart';
import 'package:mobile_app/widgets/cerca_de_ti/tarjeta_reporte_cercano.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_lista_reportes.dart';
import 'package:mobile_app/widgets/cerca_de_ti/panel_filtros_cercanos.dart';
import 'package:mobile_app/models/categoria_model.dart';

/// {@template pantalla_cerca_de_ti}
/// Pantalla que muestra una lista de reportes (pendientes y verificados)
/// cercanos a la ubicación actual del usuario.
///
/// Utiliza [geolocator] para obtener la ubicación y [ReporteService.getReportesCercanos]
/// para obtener los datos. Permite filtrar y "unirse" a reportes pendientes.
/// {@endtemplate}
class PantallaCercaDeTi extends StatefulWidget {
  /// {@macro pantalla_cerca_de_ti}
  const PantallaCercaDeTi({super.key});

  @override
  State<PantallaCercaDeTi> createState() => _PantallaCercaDeTiState();
}

/// Estado para [PantallaCercaDeTi].
///
/// Maneja la obtención de la ubicación, la carga de reportes cercanos,
/// la aplicación de filtros, y las acciones de unirse/desunirse a reportes pendientes.
/// Utiliza [WidgetsBindingObserver] para refrescar al volver a la app.
class _PantallaCercaDeTiState extends State<PantallaCercaDeTi>
    with WidgetsBindingObserver {
  /// Lista de reportes cercanos actualmente mostrados.
  List<ReporteCercano>? _reportes;
  final ReporteService _reporteService = ReporteService();
  /// Última ubicación conocida del usuario.
  LatLng? _lastKnownLocation;
  /// Filtros actualmente aplicados a la lista.
  FiltrosCercanos _filtrosAplicados = FiltrosCercanos();
  /// Lista de categorías disponibles para el filtro.
  List<Categoria> _categoriasDisponibles = [];
  /// Indica si se están cargando las categorías.
  bool _isLoadingCategories = true;
  /// Indica si se están cargando los reportes.
  bool _isLoadingReports = false;
  /// Mensaje de error a mostrar si falla la carga.
  String? _errorMessage;

  /// Mapa para rastrear el estado de carga al unirse a un reporte.
  final Map<int, bool> _joiningStatus = {};
  /// Mapa para rastrear el estado de carga al desunirse de un reporte.
  final Map<int, bool> _unjoiningStatus = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeScreen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresca los reportes cuando la app vuelve a primer plano.
    if (state == AppLifecycleState.resumed) {
      _fetchNearbyReports(forceLocation: false, resetFilters: false);
    }
  }

  /// Carga las categorías y luego los reportes iniciales.
  Future<void> _initializeScreen() async {
    await _loadCategories();
    _fetchNearbyReports(forceLocation: true, resetFilters: true);
  }

  /// Carga las categorías desde la API si aún no se han cargado.
  Future<void> _loadCategories() async {
    if (_categoriasDisponibles.isEmpty) {
      setState(() => _isLoadingCategories = true);
    }
    try {
      final cats = await _reporteService.getCategorias();
      if (mounted) {
        setState(() {
          _categoriasDisponibles = cats;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      debugPrint("Error cargando categorías para filtros: $e");
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  /// Obtiene la ubicación del usuario (si es necesario) y carga los reportes cercanos.
  ///
  /// [forceLocation]: Si es `true`, siempre intenta obtener una nueva ubicación GPS.
  /// [resetFilters]: Si es `true`, limpia los filtros aplicados.
  Future<void> _fetchNearbyReports(
      {bool forceLocation = false, bool resetFilters = false}) async {
    if (_isLoadingReports) {
      return;
    }

    setState(() {
      _isLoadingReports = true;
      _errorMessage = null;
      if (resetFilters) {
        _filtrosAplicados = FiltrosCercanos();
      }
    });

    LatLng? locationToUse = _lastKnownLocation;

    if (locationToUse == null || forceLocation) {
      final status = await Permission.location.request();
      if (!status.isGranted) {
        if (mounted) {
          setState(() {
            _isLoadingReports = false;
            _errorMessage = 'Se requiere permiso de ubicación.';
            _reportes = [];
          });
        }
        return;
      }
      try {
        Position position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
                timeLimit: Duration(seconds: 15)));
        locationToUse = LatLng(position.latitude, position.longitude);
        if (forceLocation || _lastKnownLocation == null) {
          _lastKnownLocation = locationToUse;
        }
      } catch (e) {
        debugPrint("Error obteniendo ubicación: $e");
        if (mounted) {
          setState(() {
            _isLoadingReports = false;
            _errorMessage = 'No se pudo obtener la ubicación GPS.';
            _reportes = [];
          });
        }
        return;
      }
    }

    try {
      final reports = await _reporteService.getReportesCercanos(locationToUse,
          filtros: _filtrosAplicados);
      if (!mounted) return;
      setState(() {
        _reportes = reports;
        _isLoadingReports = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingReports = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _reportes = [];
      });
    }
  }

  /// Maneja la acción de "unirse" a un reporte pendiente.
  Future<void> _handleJoinReport(int reporteId) async {
    if (_joiningStatus[reporteId] == true || _unjoiningStatus[reporteId] == true) {
      return;
    }

    setState(() => _joiningStatus[reporteId] = true);

    Map<String, dynamic> response = {};
    try {
      response = await _reporteService.unirseReportePendiente(reporteId);
    } catch (e) {
      response = {'statusCode': 500, 'message': 'Error inesperado.'};
      debugPrint("Error: $e");
    }

    if (!mounted) return;

    final message = response['message'] ?? 'Ocurrió un error.';
    final success = response['statusCode'] == 201 ||
        (response['statusCode'] == 200 &&
            message == 'Ya te habías unido a este reporte.');

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: success
          ? Colors.green
          : (response['statusCode'] == 403 ? Colors.orange : Colors.red),
    ));

    if (success) {
      _fetchNearbyReports(forceLocation: false, resetFilters: false);
    } else {
      setState(() {
        _joiningStatus.remove(reporteId);
      });
    }
  }

  /// Maneja la acción de "quitar apoyo" de un reporte pendiente.
  Future<void> _handleUnjoinReport(int reporteId) async {
    if (_joiningStatus[reporteId] == true || _unjoiningStatus[reporteId] == true) {
      return;
    }

    setState(() => _unjoiningStatus[reporteId] = true);

    Map<String, dynamic> response = {};
    try {
      response = await _reporteService.quitarApoyoPendiente(reporteId);
    } catch (e) {
      response = {'statusCode': 500, 'message': 'Error inesperado.'};
      debugPrint("Error en _handleUnjoinReport: $e");
    }

    if (!mounted) return;

    final message = response['message'] ?? 'Ocurrió un error.';
    final success = response['statusCode'] == 200;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.orangeAccent : Colors.red,
    ));

    if (success) {
      _fetchNearbyReports(forceLocation: false, resetFilters: false);
    } else {
      setState(() => _unjoiningStatus.remove(reporteId));
    }
  }

  /// Maneja el tap sobre una tarjeta de reporte, navegando a la pantalla de detalle.
  /// Navega a [PantallaDetallePendienteVista] si es pendiente, o a `/reporte_detalle` si es verificado.
  void _onReportTap(ReporteCercano reporte) async {
    if (reporte.estado == 'pendiente_verificacion') {
      final result = await Navigator.pushNamed(context, '/detalle_pendiente_vista',
          arguments: reporte.id);
      if (result == true && mounted) {
        _fetchNearbyReports(forceLocation: false, resetFilters: false);
      }
    } else {
      Navigator.pushNamed(context, '/reporte_detalle', arguments: reporte.id);
    }
  }

  /// Muestra el modal [PanelFiltrosCercanos].
  void _showFilterPanel() {
    if (_isLoadingCategories) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cargando categorías...')));
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PanelFiltrosCercanos(
        filtrosActuales: _filtrosAplicados,
        categoriasDisponibles: _categoriasDisponibles,
        onAplicarFiltros: (nuevosFiltros) {
          setState(() {
            _filtrosAplicados = nuevosFiltros;
            _fetchNearbyReports(forceLocation: false, resetFilters: false);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? appBarSubtitle;
    if (_isLoadingReports && _reportes == null) {
      appBarSubtitle = 'Buscando reportes...';
    } else if (_errorMessage == null && _reportes != null) {
      appBarSubtitle =
          '${_reportes!.length} reporte${_reportes!.length == 1 ? '' : 's'} encontrado${_reportes!.length == 1 ? '' : 's'}';
    } else if (_errorMessage != null) {
      appBarSubtitle = 'Error al buscar';
    }

    Widget bodyContent;

    if (_isLoadingReports && _reportes == null) {
      bodyContent = const EsqueletoListaReportes();
    } else if (_errorMessage != null) {
      bodyContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade300, size: 50),
              const SizedBox(height: 16),
              Text('Error: $_errorMessage',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Intentar de Nuevo'),
                onPressed: () => _fetchNearbyReports(forceLocation: true),
              )
            ],
          ),
        ),
      );
    } else if (_reportes == null || _reportes!.isEmpty) {
      bodyContent = const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No se encontraron reportes en un radio de 500 metros con los filtros actuales.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    } else {
      bodyContent = ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _reportes!.length,
        itemBuilder: (context, index) {
          final reporte = _reportes![index];
          return TarjetaReporteCercano(
            reporte: reporte,
            isJoining: _joiningStatus[reporte.id] ?? false,
            isUnjoining: _unjoiningStatus[reporte.id] ?? false,
            onUnjoinTap: () => _handleUnjoinReport(reporte.id),
            onCardTap: () => _onReportTap(reporte),
            onJoinTap: () => _handleJoinReport(reporte.id),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reportes Cerca de Ti'),
            if (appBarSubtitle != null)
              Text(appBarSubtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _isLoadingReports ? null : _showFilterPanel,
            tooltip: 'Filtrar reportes',
          ),
          if (!_isLoadingReports)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  _fetchNearbyReports(forceLocation: true, resetFilters: true),
              tooltip: 'Refrescar y limpiar filtros',
            )
          else
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            _fetchNearbyReports(forceLocation: true, resetFilters: false),
        child: bodyContent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/create_report');
          if (result == true && mounted) {
            _fetchNearbyReports(forceLocation: false, resetFilters: false);
          }
        },
        label: const Text('Nuevo Reporte'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}