import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_app/api/lider_service.dart';
import 'package:mobile_app/api/perfil_service.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:mobile_app/api/seguimiento_service.dart';
import 'package:mobile_app/models/reporte_resumen_model.dart';
import 'package:mobile_app/models/solicitud_revision_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_lista_actividad.dart';
import 'package:mobile_app/widgets/mi_actividad/activity_list_view.dart';
import 'package:mobile_app/widgets/mi_actividad/solicitudes_revision_view.dart';

class MiActividadScreen extends StatefulWidget {
  final PageController mainPageController;

  const MiActividadScreen({super.key, required this.mainPageController});

  @override
  State<MiActividadScreen> createState() => _MiActividadScreenState();
}

class _MiActividadScreenState extends State<MiActividadScreen>
    with TickerProviderStateMixin {
  final PerfilService _perfilService = PerfilService();
  final ReporteService _reporteService = ReporteService();
  final SeguimientoService _seguimientoService = SeguimientoService();
  final LiderService _liderService = LiderService();

  TabController? _tabController;
  bool _isLoading = true;
  bool _isLider = false;
  int _tabLength = 4;

  List<ReporteResumen> _misReportes = [];
  List<ReporteResumen> _misApoyos = [];
  List<ReporteResumen> _misSeguimientos = [];
  List<ReporteResumen> _misComentarios = [];
  List<SolicitudRevision> _misRevisiones = [];
  bool _isSwipingScreens = false;

  @override
  void initState() {
    super.initState();
    _isLider = context.read<AuthNotifier>().isLider;
    _tabLength = _isLider ? 5 : 4;
    _tabController = TabController(length: _tabLength, vsync: this);

    _tabController?.addListener(() {
      if (!_tabController!.indexIsChanging) {
        setState(() {
          _isSwipingScreens = false;
        });
      }
    });
    _fetchAllData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _fetchAllData() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    try {
      final tareas = [
        _perfilService.getMisReportes(),
        _perfilService.getMisApoyos(),
        _seguimientoService.getMisReportesSeguidos(),
        _perfilService.getMisComentarios(),
        if (_isLider) _liderService.getMisSolicitudesRevision(),
      ];
      final resultados = await Future.wait(tareas);
      if (mounted) {
        setState(() {
          _misReportes = resultados[0] as List<ReporteResumen>;
          _misApoyos = resultados[1] as List<ReporteResumen>;
          _misSeguimientos = resultados[2] as List<ReporteResumen>;
          _misComentarios = resultados[3] as List<ReporteResumen>;
          if (_isLider) {
            _misRevisiones = resultados[4] as List<SolicitudRevision>;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error cargando toda la actividad: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al cargar la actividad: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleCancelarReporte(int reporteId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar Reporte'),
        content: const Text('¿Estás seguro? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              child: const Text('No'),
              onPressed: () => Navigator.pop(ctx, false)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, Cancelar'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await _reporteService.eliminarReporte(reporteId);
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Reporte cancelado exitosamente.'),
                  backgroundColor: Colors.green),
            );
            _fetchAllData();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('No se pudo cancelar el reporte.'),
                  backgroundColor: Colors.red),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _handleNavigateToDetail(int reporteId) async {
    final result = await Navigator.pushNamed(context, '/reporte_detalle',
        arguments: reporteId);
    if (result == true && mounted) {
      _fetchAllData();
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is OverscrollNotification) {
      if (_isSwipingScreens) {
        return false;
      }

      if (notification.overscroll < 0 && _tabController?.index == 0) {
        setState(() => _isSwipingScreens = true);
        widget.mainPageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        return true;
      }

      if (notification.overscroll > 0 &&
          _tabController?.index == _tabLength - 1) {
        setState(() => _isSwipingScreens = true);
        widget.mainPageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final List<Tab> tabs = [
      Tab(text: 'Mis Reportes (${_isLoading ? '...' : _misReportes.length})'),
      Tab(text: 'Mis Apoyos (${_isLoading ? '...' : _misApoyos.length})'),
      Tab(text: 'Seguidos (${_isLoading ? '...' : _misSeguimientos.length})'),
      Tab(text: 'Comentarios (${_isLoading ? '...' : _misComentarios.length})'),
      if (_isLider)
        Tab(text: 'Revisiones (${_isLoading ? '...' : _misRevisiones.length})'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Actividad'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: tabs,
        ),
      ),
      body: _isLoading && _misReportes.isEmpty
          ? const EsqueletoListaActividad()
          : NotificationListener<ScrollNotification>(
              onNotification: _handleScrollNotification,
              child: TabBarView(
                controller: _tabController,
                children: [
                  ActivityListView(
                    fetcher: Fetcher.misReportes,
                    reportes: _misReportes,
                    isLoading: _isLoading,
                    onRefresh: _fetchAllData,
                    onCancelarReporte: _handleCancelarReporte,
                    onNavigateToDetail: _handleNavigateToDetail,
                  ),
                  ActivityListView(
                    fetcher: Fetcher.misApoyos,
                    reportes: _misApoyos,
                    isLoading: _isLoading,
                    onRefresh: _fetchAllData,
                    onCancelarReporte: (id) {},
                    onNavigateToDetail: _handleNavigateToDetail,
                  ),
                  ActivityListView(
                    fetcher: Fetcher.misSeguimientos,
                    reportes: _misSeguimientos,
                    isLoading: _isLoading,
                    onRefresh: _fetchAllData,
                    onCancelarReporte: (id) {},
                    onNavigateToDetail: _handleNavigateToDetail,
                  ),
                  ActivityListView(
                    fetcher: Fetcher.misComentarios,
                    reportes: _misComentarios,
                    isLoading: _isLoading,
                    onRefresh: _fetchAllData,
                    onCancelarReporte: (id) {},
                    onNavigateToDetail: _handleNavigateToDetail,
                  ),
                  if (_isLider)
                    SolicitudesRevisionView(
                      solicitudes: _misRevisiones,
                      isLoading: _isLoading,
                      onRefresh: _fetchAllData,
                    ),
                ],
              ),
            ),
    );
  }
}
