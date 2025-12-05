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
/// Pantalla principal que muestra reportes en un radio cercano.
///
/// Características Actualizadas:
/// 1. Prioriza visualmente los reportes a los que el usuario se ha unido.
/// 2. Permite Unirse/Desunirse con actualización inmediata de la UI (sin recarga total).
/// 3. Sincronización bidireccional de estado con la pantalla de detalles.
/// {@endtemplate}
class PantallaCercaDeTi extends StatefulWidget {
  const PantallaCercaDeTi({super.key});

  @override
  State<PantallaCercaDeTi> createState() => _PantallaCercaDeTiState();
}

class _PantallaCercaDeTiState extends State<PantallaCercaDeTi>
    with WidgetsBindingObserver {
  /// Lista de reportes que se muestran en pantalla.
  List<ReporteCercano>? _reportes;
  final ReporteService _reporteService = ReporteService();
  
  /// Última ubicación GPS validada.
  LatLng? _lastKnownLocation;
  
  /// Filtros activos.
  FiltrosCercanos _filtrosAplicados = FiltrosCercanos();
  
  /// Categorías para el modal de filtros.
  List<Categoria> _categoriasDisponibles = [];
  
  // Estados de carga generales
  bool _isLoadingCategories = true;
  bool _isLoadingReports = false;
  String? _errorMessage;

  /// Mapas para controlar el estado de carga ("spinner") de cada tarjeta individualmente.
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

  /// Recarga los datos al volver a la app desde segundo plano.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _fetchNearbyReports(forceLocation: false, resetFilters: false);
    }
  }

  /// Carga inicial: Categorías -> Ubicación -> Reportes.
  Future<void> _initializeScreen() async {
    await _loadCategories();
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
      debugPrint("Error cargando categorías: $e");
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  /// Obtiene reportes cercanos desde la API.
  Future<void> _fetchNearbyReports(
      {bool forceLocation = false, bool resetFilters = false}) async {
    if (_isLoadingReports) return;

    setState(() {
      _isLoadingReports = true;
      _errorMessage = null;
      if (resetFilters) _filtrosAplicados = FiltrosCercanos();
    });

    LatLng? locationToUse = _lastKnownLocation;

    // Lógica de obtención de ubicación GPS
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
      // Aseguramos el orden correcto tras la carga inicial
      _sortReportsLocal();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingReports = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _reportes = [];
      });
    }
  }

  /// Muestra un diálogo de confirmación genérico.
  Future<bool> _confirmAction(String title, String content, String confirmText, Color confirmColor) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor, foregroundColor: Colors.white),
            child: Text(confirmText),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Reordena la lista localmente para reflejar cambios inmediatos.
  void _sortReportsLocal() {
    if (_reportes == null) return;
    _reportes!.sort((a, b) {
      // Comparar estado de unión (booleano)
      if (a.usuarioActualUnido && !b.usuarioActualUnido) return -1; // a va antes
      if (!a.usuarioActualUnido && b.usuarioActualUnido) return 1;  // b va antes
      
      // Si ambos tienen el mismo estado de unión, comparar distancia
      return a.distanciaMetros.compareTo(b.distanciaMetros);
    });
  }

  /// Maneja la acción de UNIRSE a un reporte.
  Future<void> _handleJoinReport(int reporteId) async {
    final confirm = await _confirmAction(
      '¿Unirse al reporte?', 
      'Confirmas que este reporte es real y deseas apoyarlo para su verificación.', 
      'Sí, Unirme', 
      Colors.green
    );
    if (!confirm) return;

    if (_joiningStatus[reporteId] == true) return;

    setState(() => _joiningStatus[reporteId] = true);

    try {
      final response = await _reporteService.unirseReportePendiente(reporteId);
      
      if (!mounted) return;

      final message = response['message'] ?? 'Ocurrió un error.';
      final success = response['statusCode'] == 201 ||
          (response['statusCode'] == 200 && message.contains('Ya te habías unido'));

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ));

      if (success) {
        setState(() {
          final index = _reportes?.indexWhere((r) => r.id == reporteId);
          if (index != null && index != -1 && _reportes != null) {
             final old = _reportes![index];
             _reportes![index] = ReporteCercano(
               id: old.id,
               titulo: old.titulo,
               categoria: old.categoria,
               estado: old.estado,
               fotoUrl: old.fotoUrl,
               apoyosPendientes: (response['currentApoyos'] ?? old.apoyosPendientes + 1),
               idUsuario: old.idUsuario,
               autor: old.autor,
               fechaCreacionFormateada: old.fechaCreacionFormateada,
               esPrioritario: old.esPrioritario,
               urgencia: old.urgencia,
               distanciaMetros: old.distanciaMetros,
               usuarioActualUnido: true,
               puedeUnirse: false,
             );
             _sortReportsLocal();
          }
          _joiningStatus.remove(reporteId);
        });
      } else {
        setState(() => _joiningStatus.remove(reporteId));
      }
    } catch (e) {
      debugPrint("Error al unirse: $e");
      if (mounted) {
        setState(() => _joiningStatus.remove(reporteId));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de conexión'), backgroundColor: Colors.red));
      }
    }
  }

  /// Maneja la acción de QUITAR APOYO.
  Future<void> _handleUnjoinReport(int reporteId) async {
    final confirm = await _confirmAction(
      '¿Quitar apoyo?', 
      '¿Estás seguro de que deseas retirar tu apoyo a este reporte?', 
      'Sí, Quitar', 
      Colors.redAccent
    );
    if (!confirm) return;

    if (_unjoiningStatus[reporteId] == true) return;

    setState(() => _unjoiningStatus[reporteId] = true);

    try {
      final response = await _reporteService.quitarApoyoPendiente(reporteId);
      
      if (!mounted) return;

      final message = response['message'] ?? 'Ocurrió un error.';
      final success = response['statusCode'] == 200;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.orange : Colors.red,
      ));

      if (success) {
        setState(() {
          final index = _reportes?.indexWhere((r) => r.id == reporteId);
          if (index != null && index != -1 && _reportes != null) {
             final old = _reportes![index];
             _reportes![index] = ReporteCercano(
               id: old.id,
               titulo: old.titulo,
               categoria: old.categoria,
               estado: old.estado,
               fotoUrl: old.fotoUrl,
               apoyosPendientes: (response['currentApoyos'] ?? (old.apoyosPendientes - 1 < 0 ? 0 : old.apoyosPendientes - 1)),
               idUsuario: old.idUsuario,
               autor: old.autor,
               fechaCreacionFormateada: old.fechaCreacionFormateada,
               esPrioritario: old.esPrioritario,
               urgencia: old.urgencia,
               distanciaMetros: old.distanciaMetros,
               usuarioActualUnido: false,
               puedeUnirse: true,
             );
             _sortReportsLocal();
          }
          _unjoiningStatus.remove(reporteId);
        });
      } else {
        setState(() => _unjoiningStatus.remove(reporteId));
      }
    } catch (e) {
      debugPrint("Error al quitar apoyo: $e");
      if (mounted) {
        setState(() => _unjoiningStatus.remove(reporteId));
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de conexión'), backgroundColor: Colors.red));
      }
    }
  }

  // --- CORRECCIÓN CRÍTICA: Comunicación Bidireccional ---
  void _onReportTap(ReporteCercano reporte) async {
    if (reporte.estado == 'pendiente_verificacion') {
      // 1. Enviamos el estado actual al detalle
      final result = await Navigator.pushNamed(
        context, 
        '/detalle_pendiente_vista',
        arguments: {
          'id': reporte.id,
          'isJoined': reporte.usuarioActualUnido, // Pasamos estado inicial
          'apoyosCount': reporte.apoyosPendientes // Pasamos conteo inicial
        }
      );
      
      // 2. Si recibimos un resultado tipo Map, significa que hubo cambios en la pantalla detalle
      if (result is Map && mounted) {
         final bool nuevoEstadoJoined = result['isJoined'];
         final int nuevoConteo = result['apoyosCount'];
         
         // 3. Actualizamos la lista localmente SIN llamar a la API
         setState(() {
            final index = _reportes?.indexWhere((r) => r.id == reporte.id);
            if (index != null && index != -1 && _reportes != null) {
               final old = _reportes![index];
               _reportes![index] = ReporteCercano(
                 id: old.id,
                 titulo: old.titulo,
                 categoria: old.categoria,
                 estado: old.estado,
                 fotoUrl: old.fotoUrl,
                 apoyosPendientes: nuevoConteo, // Actualizamos conteo
                 idUsuario: old.idUsuario,
                 autor: old.autor,
                 fechaCreacionFormateada: old.fechaCreacionFormateada,
                 esPrioritario: old.esPrioritario,
                 urgencia: old.urgencia,
                 distanciaMetros: old.distanciaMetros,
                 usuarioActualUnido: nuevoEstadoJoined, // Actualizamos estado
                 puedeUnirse: !nuevoEstadoJoined, // Si está unido, no puede unirse (y viceversa)
               );
               _sortReportsLocal(); // Reordenamos si cambió el estado
            }
         });
      } else if (result == true && mounted) {
        // Fallback: Si devuelve true genérico, recargamos todo
        _fetchNearbyReports(forceLocation: false, resetFilters: false);
      }
    } else {
      Navigator.pushNamed(context, '/reporte_detalle', arguments: reporte.id);
    }
  }

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
              Text('Error: $_errorMessage', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
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