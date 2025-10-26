// lib/screens/verificacion_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/api/lider_service.dart';
import 'package:mobile_app/widgets/verificacion/lista_reportes_verificacion.dart';
import 'package:mobile_app/widgets/verificacion/mis_reportes_moderacion_view.dart';

class VerificacionScreen extends StatefulWidget {
  final PageController mainPageController;
  const VerificacionScreen({
    super.key,
    required this.mainPageController,
  });

  @override
  State<VerificacionScreen> createState() => _VerificacionScreenState();
}

class _VerificacionScreenState extends State<VerificacionScreen>
    with TickerProviderStateMixin {
  final LiderService _liderService = LiderService();
  TabController? _tabController;
  bool _isLoadingStats = true;
  Map<String, int?> _stats = {
    'pendientes': null,
    'historial': null,
    'misReportes': null
  };
  final int _tabLength = 3;

  final GlobalKey<ListaReportesVerificacionState> _pendientesKey =
      GlobalKey<ListaReportesVerificacionState>();
  final GlobalKey<ListaReportesVerificacionState> _historialKey =
      GlobalKey<ListaReportesVerificacionState>();
  final GlobalKey<MisReportesModeracionViewState> _misReportesKey =
      GlobalKey<MisReportesModeracionViewState>();

  List<String> _zonasAsignadas = [];
  bool _isLoadingZonas = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLength, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadStats(isRefresh: true),
      _loadZonasAsignadas(),
    ]);
  }

  Future<void> _loadStats({bool isRefresh = false}) async {
    if (!isRefresh && !_isLoadingStats && _stats.values.every((v) => v != null))
      return;
    if (mounted) setState(() => _isLoadingStats = true);
    try {
      final fetchedStats = await _liderService.getModeracionStats();
      if (mounted) {
        setState(() {
          _stats = fetchedStats.map((key, value) => MapEntry(key, value));
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      print("Error cargando stats de moderación: $e");
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
          _stats = {'pendientes': null, 'historial': null, 'misReportes': null};
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al cargar contadores: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadZonasAsignadas() async {
    if (mounted) setStateIfMounted(() => _isLoadingZonas = true); // Usar helper
    try {
      final zonas = await _liderService.getMisZonasAsignadas();
      if (mounted) {
        setStateIfMounted(() {
          // Usar helper
          _zonasAsignadas = zonas;
          _isLoadingZonas = false;
        });
      }
    } catch (e) {
      print("Error cargando zonas asignadas: $e");
      if (mounted)
        setStateIfMounted(() => _isLoadingZonas = false); // Usar helper
    }
  }

  // Helper para evitar llamar a setState si el widget se desmontó
  void setStateIfMounted(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  Future<void> _handleTabRefresh() async {
    if (!mounted) return;
    setStateIfMounted(() => _isLoadingStats = true); // Indicador general

    int? newCount;
    String currentTabKey = '';
    Future<int>? refreshFuture;

    switch (_tabController?.index) {
      case 0:
        refreshFuture = _pendientesKey.currentState?.refreshData();
        currentTabKey = 'pendientes';
        break;
      case 1:
        refreshFuture = _historialKey.currentState?.refreshData();
        currentTabKey = 'historial';
        break;
      case 2:
        refreshFuture = _misReportesKey.currentState?.refreshData();
        currentTabKey = 'misReportes';
        break;
    }

    try {
      // Ejecutar refresh de pestaña Y recarga de zonas en paralelo
      final results = await Future.wait([
        _loadZonasAsignadas(), // Recargar zonas asignadas
        if (refreshFuture != null)
          refreshFuture
        else
          Future.value(null), // Refresh de pestaña
      ]);

      newCount = results[1] as int?;

      if (mounted && currentTabKey.isNotEmpty) {
        setStateIfMounted(() {
          // Usar helper
          _stats[currentTabKey] = newCount;
          _isLoadingStats = false;
        });
      } else if (mounted) {
        setStateIfMounted(() => _isLoadingStats = false); // Usar helper
      }
    } catch (e) {
      print("Error durante refresh: $e");
      if (mounted) {
        setStateIfMounted(() => _isLoadingStats = false); // Usar helper
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al refrescar: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String countText(String key) {
      final count = _stats[key];
      // Mostrar '...' si está cargando O si el count es null (falló la carga inicial)
      return (_isLoadingStats && count == null)
          ? '...'
          : (count?.toString() ?? '-');
    }

    final List<Tab> tabs = [
      Tab(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.pending_actions_outlined),
          const SizedBox(width: 8),
          Text('Pendientes (${countText('pendientes')})'),
        ]),
      ),
      Tab(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.history_outlined),
          const SizedBox(width: 8),
          Text('Historial (${countText('historial')})'),
        ]),
      ),
      Tab(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.flag_outlined),
          const SizedBox(width: 8),
          Text('Mis Reportes (${countText('misReportes')})'),
        ]),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Quitar flecha de back
        flexibleSpace: _VerificacionHeader(
          isLoadingZonas: _isLoadingZonas,
          zonasAsignadas: _zonasAsignadas,
        ),
        toolbarHeight: 80, // Ajustar según diseño final del header
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
          isScrollable: MediaQuery.of(context).size.width < 600,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListaReportesVerificacion(key: _pendientesKey, isHistory: false),
          ListaReportesVerificacion(key: _historialKey, isHistory: true),
          MisReportesModeracionView(key: _misReportesKey),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoadingStats ? null : _handleTabRefresh,
        tooltip: 'Refrescar',
        child: _isLoadingStats
            ? const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              )
            : const Icon(Icons.refresh),
      ),
    );
  }
}

// --- CORRECCIÓN: Header con más espacio y texto multilínea ---
class _VerificacionHeader extends StatelessWidget {
  final bool isLoadingZonas;
  final List<String> zonasAsignadas;

  const _VerificacionHeader({
    required this.isLoadingZonas,
    required this.zonasAsignadas,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String zonasText;
    if (isLoadingZonas) {
      zonasText = 'Cargando zonas...';
    } else if (zonasAsignadas.isEmpty) {
      zonasText = 'Sin zonas asignadas';
    } else if (zonasAsignadas.contains('*')) {
      zonasText = 'Gestionando: Todas las Zonas';
    } else {
      zonasText = 'Gestionando: ${zonasAsignadas.join(', ')}';
    }

    return SafeArea(
      child: Container(
        // --- CORRECCIÓN: Usar Padding en lugar de Margin ---
        padding: const EdgeInsets.fromLTRB(
            16.0, 8.0, 16.0, 12.0), // Más espacio abajo (bottom: 12.0)
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Panel de Moderación',
              style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.appBarTheme.titleTextStyle?.color ??
                      (theme.brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black), // Color adaptable
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            // --- CORRECCIÓN: Permitir múltiples líneas ---
            Text(
              zonasText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: (theme.appBarTheme.titleTextStyle?.color ??
                        (theme.brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black))
                    .withOpacity(0.8), // Color adaptable
              ),
              // Quitar maxLines y overflow para permitir wrap
            ),
            const SizedBox(height: 8),
            // --- FIN CORRECCIÓN ---
          ],
        ),
      ),
    );
  }
}
// --- FIN CORRECCIÓN ---
