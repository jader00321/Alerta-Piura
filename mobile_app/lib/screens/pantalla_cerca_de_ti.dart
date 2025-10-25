// lib/screens/pantalla_cerca_de_ti.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:mobile_app/models/reporte_cercano_model.dart'; // Asegúrate que la importación sea correcta
import 'package:mobile_app/widgets/cerca_de_ti/tarjeta_reporte_cercano.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_lista_reportes.dart';
import 'package:mobile_app/widgets/cerca_de_ti/panel_filtros_cercanos.dart';
import 'package:mobile_app/models/categoria_model.dart';

class PantallaCercaDeTi extends StatefulWidget {
  const PantallaCercaDeTi({super.key});

  @override
  State<PantallaCercaDeTi> createState() => _PantallaCercaDeTiState();
}

class _PantallaCercaDeTiState extends State<PantallaCercaDeTi> with WidgetsBindingObserver {
  List<ReporteCercano>? _reportes;
  final ReporteService _reporteService = ReporteService();
  LatLng? _lastKnownLocation;
  FiltrosCercanos _filtrosAplicados = FiltrosCercanos(); // Mantiene los filtros actuales
  List<Categoria> _categoriasDisponibles = [];
  bool _isLoadingCategories = true;
  bool _isLoadingReports = false;
  String? _errorMessage;

  final Map<int, bool> _joiningStatus = {};
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
    if (state == AppLifecycleState.resumed) {
      // Refresh usando última ubicación conocida y manteniendo filtros
      _fetchNearbyReports(forceLocation: false, resetFilters: false);
    }
  }

  Future<void> _initializeScreen() async {
    await _loadCategories();
    // Fetch inicial fuerza nueva ubicación y no tiene filtros
    _fetchNearbyReports(forceLocation: true, resetFilters: true);
  }

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
      print("Error cargando categorías para filtros: $e");
      if(mounted) setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _fetchNearbyReports({bool forceLocation = false, bool resetFilters = false}) async {
    if (_isLoadingReports) return;

    setState(() {
      _isLoadingReports = true;
      _errorMessage = null;
      if (resetFilters) {
        _filtrosAplicados = FiltrosCercanos(); // Resetea filtros si se solicita
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
           desiredAccuracy: LocationAccuracy.high,
           timeLimit: const Duration(seconds: 15),
         );
         locationToUse = LatLng(position.latitude, position.longitude);
         // Actualiza lastKnownLocation si se forzó o no existía
         if (forceLocation || _lastKnownLocation == null) {
            _lastKnownLocation = locationToUse;
         }
       } catch (e) {
         print("Error obteniendo ubicación: $e");
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

    // ignore: unnecessary_null_comparison
    if (locationToUse == null) {
       if (mounted) {
          setState(() {
             _isLoadingReports = false;
             _errorMessage = 'Ubicación no determinada.';
             _reportes = [];
          });
       }
       return;
     }

    try {
      // Pasa los filtros actuales (_filtrosAplicados) al servicio
      final reports = await _reporteService.getReportesCercanos(locationToUse, filtros: _filtrosAplicados);
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


  Future<void> _handleJoinReport(int reporteId) async {
    if (_joiningStatus[reporteId] == true || _unjoiningStatus[reporteId] == true) return; // Evitar si ya hay acción en curso

    setState(() => _joiningStatus[reporteId] = true);

    Map<String, dynamic> response = {};
    try { response = await _reporteService.unirseReportePendiente(reporteId); }
    catch (e) { response = {'statusCode': 500, 'message': 'Error inesperado.'}; print("Error: $e"); }

    if (!mounted) return;

    final message = response['message'] ?? 'Ocurrió un error.';
    final success = response['statusCode'] == 201 || (response['statusCode'] == 200 && message == 'Ya te habías unido a este reporte.');

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green : (response['statusCode'] == 403 ? Colors.orange : Colors.red),
    ));

    if (success) {
      // Refrescar lista SIN forzar nueva ubicación y manteniendo filtros
      _fetchNearbyReports(forceLocation: false, resetFilters: false);
      // El estado de _joiningStatus se limpiará automáticamente con el refresh
    } else {
       // Quitar estado de carga SIEMPRE si no hubo éxito o si no se refresca
       setState(() {
          _joiningStatus.remove(reporteId);
       });
    }
  }

  Future<void> _handleUnjoinReport(int reporteId) async {
    if (_joiningStatus[reporteId] == true || _unjoiningStatus[reporteId] == true) return; // Evitar si ya hay acción en curso

    setState(() => _unjoiningStatus[reporteId] = true); // Marcar como quitando apoyo

    Map<String, dynamic> response = {};
    try {
      response = await _reporteService.quitarApoyoPendiente(reporteId); // Llamar al nuevo servicio
    } catch (e) {
      response = {'statusCode': 500, 'message': 'Error inesperado.'};
      print("Error en _handleUnjoinReport: $e");
    }

    if (!mounted) return;

    final message = response['message'] ?? 'Ocurrió un error.';
    final success = response['statusCode'] == 200; // 200 OK para éxito al quitar

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.orangeAccent : Colors.red, // Naranja para éxito al quitar
    ));

    if (success) {
      _fetchNearbyReports(forceLocation: false, resetFilters: false); // Refresca y limpia estado
    } else {
      setState(() => _unjoiningStatus.remove(reporteId)); // Limpia estado si falla
    }
  }

  // --- MODIFICADO: Ahora navega a la nueva pantalla para pendientes ---
  void _onReportTap(ReporteCercano reporte) async {
    if (reporte.estado == 'pendiente_verificacion') {
      // Navega a la pantalla de vista detallada pendiente
      final result = await Navigator.pushNamed(context, '/detalle_pendiente_vista', arguments: reporte.id);
      // Si esa pantalla devuelve true (porque se unió), refrescar aquí
      if (result == true && mounted) {
          _fetchNearbyReports(forceLocation: false, resetFilters: false);
      }
    } else {
      // Para reportes verificados, navegar a la pantalla de detalle normal
      Navigator.pushNamed(context, '/reporte_detalle', arguments: reporte.id);
    }
  }


  void _showFilterPanel() {
    if (_isLoadingCategories) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cargando categorías...')));
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Importante para DraggableScrollableSheet
      backgroundColor: Colors.transparent,
      builder: (context) => PanelFiltrosCercanos( // Usar el widget corregido
        filtrosActuales: _filtrosAplicados,
        categoriasDisponibles: _categoriasDisponibles,
        onAplicarFiltros: (nuevosFiltros) {
          setState(() {
            _filtrosAplicados = nuevosFiltros;
            // Refrescar con nuevos filtros, usar última ubicación
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
      appBarSubtitle = '${_reportes!.length} reporte${_reportes!.length == 1 ? '' : 's'} encontrado${_reportes!.length == 1 ? '' : 's'}';
    } else if (_errorMessage != null) {
        appBarSubtitle = 'Error al buscar';
    }

    Widget bodyContent;

    if (_isLoadingReports && _reportes == null) {
      // Show skeleton only on initial load
      bodyContent = const EsqueletoListaReportes();
    } else if (_errorMessage != null) {
      // Show error message
      bodyContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Icon(Icons.error_outline, color: Colors.red.shade300, size: 50),
               const SizedBox(height: 16),
               Text('Error: $_errorMessage', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
               const SizedBox(height: 16),
               ElevatedButton.icon(
                 icon: const Icon(Icons.refresh),
                 label: const Text('Intentar de Nuevo'),
                 onPressed: () => _fetchNearbyReports(forceLocation: true), // Force location on manual retry
               )
            ],
          ),
        ),
      );
    } else if (_reportes == null || _reportes!.isEmpty) {
       // Show empty message (handles both null _reportes initially and empty list after load)
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
      // Show the list of reports
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
          // Show refresh button only if not currently loading
          if (!_isLoadingReports)
            IconButton(
              icon: const Icon(Icons.refresh),
              // Botón Refrescar: Resetea filtros y busca NUEVA ubicación
              onPressed: () => _fetchNearbyReports(forceLocation: true, resetFilters: true),
              tooltip: 'Refrescar y limpiar filtros',
            )
          else // Show a loading indicator in app bar during refresh
             const Padding(
               padding: EdgeInsets.only(right: 16.0),
               child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
             ),
        ],
      ),
      // Pull-to-refresh: Mantiene filtros, busca NUEVA ubicación
      body: RefreshIndicator(
        onRefresh: () => _fetchNearbyReports(forceLocation: true, resetFilters: false),
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