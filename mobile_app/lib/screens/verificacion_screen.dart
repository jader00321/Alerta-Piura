import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_app/api/lider_service.dart';
import 'package:mobile_app/widgets/verificacion/lista_reportes_verificacion.dart';
import 'package:mobile_app/widgets/verificacion/mis_reportes_moderacion_view.dart';

/// {@template verificacion_screen}
/// Pantalla principal para el rol de Líder Vecinal.
///
/// Contiene pestañas para:
/// - Reportes Pendientes de verificación.
/// - Historial de moderaciones realizadas por el líder.
/// - Reportes de contenido (comentarios/usuarios) creados por el líder.
///
/// Muestra las zonas asignadas al líder en la cabecera.
/// {@endtemplate}
class VerificacionScreen extends StatefulWidget {
  /// El [PageController] de la [HomeScreen] principal, usado para
  /// permitir la navegación por swipe desde las pestañas internas de esta pantalla.
  final PageController mainPageController;

  /// {@macro verificacion_screen}
  const VerificacionScreen({
    super.key,
    required this.mainPageController,
  });

  @override
  State<VerificacionScreen> createState() => _VerificacionScreenState();
}

/// Estado para [VerificacionScreen].
///
/// Maneja el [TabController], la carga de estadísticas y zonas asignadas,
/// y coordina el refresco de las listas en las pestañas.
class _VerificacionScreenState extends State<VerificacionScreen>
    with TickerProviderStateMixin {
  final LiderService _liderService = LiderService();
  TabController? _tabController;
  bool _isLoadingStats = true;
  /// Contadores para las pestañas (pendientes, historial, mis reportes).
  Map<String, int?> _stats = {
    'pendientes': null,
    'historial': null,
    'misReportes': null
  };
  final int _tabLength = 3;

  /// Claves globales para acceder a los estados de los widgets de lista
  /// y llamar a sus métodos `refreshData`.
  final GlobalKey<ListaReportesVerificacionState> _pendientesKey =
      GlobalKey<ListaReportesVerificacionState>();
  final GlobalKey<ListaReportesVerificacionState> _historialKey =
      GlobalKey<ListaReportesVerificacionState>();
  final GlobalKey<MisReportesModeracionViewState> _misReportesKey =
      GlobalKey<MisReportesModeracionViewState>();

  /// Lista de distritos asignados al líder.
  List<String> _zonasAsignadas = [];
  /// Indica si se están cargando las zonas asignadas.
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

  /// Carga las estadísticas y las zonas asignadas al inicio.
  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadStats(isRefresh: true),
      _loadZonasAsignadas(),
    ]);
  }

  /// Carga o recarga las estadísticas (contadores) para las pestañas.
  Future<void> _loadStats({bool isRefresh = false}) async {
    // Evita recargar si ya están cargadas y no es un refresh forzado
    if (!isRefresh && !_isLoadingStats && _stats.values.every((v) => v != null)) {
      return;
    }
    if (mounted) {
      setState(() => _isLoadingStats = true);
    }
    try {
      final fetchedStats = await _liderService.getModeracionStats();
      if (mounted) {
        setState(() {
          _stats = fetchedStats.map((key, value) => MapEntry(key, value));
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      debugPrint("Error cargando stats de moderación: $e");
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

  /// Carga la lista de zonas asignadas al líder.
  Future<void> _loadZonasAsignadas() async {
    if (mounted) {
      setStateIfMounted(() => _isLoadingZonas = true);
    }
    try {
      final zonas = await _liderService.getMisZonasAsignadas();
      if (mounted) {
        setStateIfMounted(() {
          _zonasAsignadas = zonas;
          _isLoadingZonas = false;
        });
      }
    } catch (e) {
      debugPrint("Error cargando zonas asignadas: $e");
      if (mounted) {
        setStateIfMounted(() => _isLoadingZonas = false);
        // Podría mostrarse un error si es crítico
      }
    }
  }

  /// Helper para llamar a setState solo si el widget está montado.
  void setStateIfMounted(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  /// Refresca los datos de la pestaña actualmente activa y las zonas asignadas.
  /// Llama al método `refreshData` del widget de lista correspondiente
  /// usando su `GlobalKey`.
  Future<void> _handleTabRefresh() async {
    if (!mounted) return;
    setStateIfMounted(() => _isLoadingStats = true); // Mostrar indicador de carga global

    int? newCount;
    String currentTabKey = '';
    Future<int>? refreshFuture;

    // Determina qué lista refrescar según la pestaña activa
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
      // Ejecuta el refresco de la lista y la carga de zonas en paralelo
      final results = await Future.wait([
        _loadZonasAsignadas(), // Recargar zonas por si cambiaron
        if (refreshFuture != null) refreshFuture else Future.value(null),
      ]);

      newCount = results[1] as int?; // El resultado del refresh de la lista

      if (mounted) {
        if (currentTabKey.isNotEmpty && newCount != null) {
          // Actualiza el contador de la pestaña refrescada
          setStateIfMounted(() {
            _stats[currentTabKey] = newCount;
            _isLoadingStats = false;
          });
        } else {
          // Si no hubo refresh de lista o falló, al menos quitar el indicador global
          setStateIfMounted(() => _isLoadingStats = false);
        }
      }
    } catch (e) {
      debugPrint("Error durante refresh: $e");
      if (mounted) {
        setStateIfMounted(() => _isLoadingStats = false);
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
    // Helper para mostrar el contador o '...' si está cargando
    String countText(String key) {
      final count = _stats[key];
      return (_isLoadingStats && count == null) ? '...' : (count?.toString() ?? '-');
    }

    // Define las pestañas con sus contadores
    final List<Tab> tabs = [
      Tab(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pending_actions_outlined),
              const SizedBox(width: 8),
              Text('Pendientes (${countText('pendientes')})'),
            ]),
      ),
      Tab(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.history_outlined),
              const SizedBox(width: 8),
              Text('Historial (${countText('historial')})'),
            ]),
      ),
      Tab(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flag_outlined),
              const SizedBox(width: 8),
              Text('Mis Reportes (${countText('misReportes')})'),
            ]),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Oculta el botón de retroceso
        flexibleSpace: _VerificacionHeader( // Cabecera personalizada
          isLoadingZonas: _isLoadingZonas,
          zonasAsignadas: _zonasAsignadas,
        ),
        toolbarHeight: 80, // Altura para la cabecera personalizada
        bottom: TabBar( // Pestañas debajo de la cabecera
          controller: _tabController,
          tabs: tabs,
          isScrollable: MediaQuery.of(context).size.width < 600, // Hace scroll si no caben
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          /// Lista de reportes pendientes
          ListaReportesVerificacion(key: _pendientesKey, isHistory: false),
          /// Lista del historial de moderación
          ListaReportesVerificacion(key: _historialKey, isHistory: true),
          /// Lista de reportes de contenido creados por el líder
          MisReportesModeracionView(key: _misReportesKey),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoadingStats ? null : _handleTabRefresh, // Refresca la pestaña actual
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

/// Widget interno para la cabecera personalizada del [AppBar].
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
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
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
                          : Colors.black),
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              zonasText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: (theme.appBarTheme.titleTextStyle?.color ??
                        (theme.brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black))
                    .withAlpha(204),
              ),
              // Permite múltiples líneas si la lista de zonas es larga
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}