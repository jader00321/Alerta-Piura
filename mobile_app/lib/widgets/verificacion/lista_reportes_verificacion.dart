// lib/widgets/verificacion/lista_reportes_verificacion.dart
import 'dart:async';
import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
import 'package:mobile_app/api/lider_service.dart';
import 'package:mobile_app/models/reporte_pendiente_model.dart';
import 'package:mobile_app/models/reporte_historial_moderado_model.dart';
import 'package:mobile_app/models/categoria_model.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:mobile_app/models/solicitud_revision_model.dart';
// Importar esqueletos y tarjetas
import 'package:mobile_app/widgets/esqueletos/esqueleto_lista_actividad.dart';
import 'package:mobile_app/widgets/verificacion/tarjeta_verificacion.dart';
import 'package:mobile_app/widgets/verificacion/tarjeta_historial_moderado.dart';
// Importar nuevos widgets de filtros
import 'package:mobile_app/widgets/verificacion/filtros_pendientes.dart';
import 'package:mobile_app/widgets/verificacion/filtros_historial.dart';
import 'package:mobile_app/widgets/verificacion/dialogo_solicitud_revision.dart';

// Enums para filtros (se quedan aquí para que los widgets los usen)
enum FiltroPendiente { todos, prioritarios, conApoyos }

enum FiltroHistorialEstado { todos, verificado, rechazado, fusionado }

class ListaReportesVerificacion extends StatefulWidget {
  final bool isHistory;

  const ListaReportesVerificacion({
    required Key key,
    this.isHistory = false,
  }) : super(key: key);

  @override
  State<ListaReportesVerificacion> createState() =>
      ListaReportesVerificacionState();
}

class ListaReportesVerificacionState extends State<ListaReportesVerificacion>
    with AutomaticKeepAliveClientMixin {
  // --- ESTADO Y SERVICIOS ---
  final LiderService _liderService = LiderService();
  final ReporteService _reporteService = ReporteService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _reportes = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  Timer? _debounce;
  int _totalFiltrado = 0;

  // Filtros Pendientes
  FiltroPendiente _filtroPendiente = FiltroPendiente.todos;
  int? _filtroCategoriaId;
  String _searchTerm = '';
  String _sortBy = 'fecha_asc'; // Más antiguo primero

  // Filtros Historial
  FiltroHistorialEstado _filtroHistorialEstado = FiltroHistorialEstado.todos;
  DateTime? _startDate;
  DateTime? _endDate;
  Map<int, String> _estadoSolicitudes = {};
  bool _isLoadingSolicitudes = false;

  List<Categoria> _categoriasDisponibles = [];
  bool _isLoadingCategories = false;

  final Map<int, bool> _isRequestingReview = {};

  // --- CICLO DE VIDA ---
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (widget.isHistory) {
      final now = DateTime.now();
      _startDate = now.subtract(const Duration(days: 7));
      _endDate = now;
    }
    refreshData(); // Carga inicial
    _scrollController.addListener(_onScroll);
    if (!widget.isHistory) {
      _searchController.addListener(_onSearchChanged);
      _loadCategories();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Helper para setState seguro
  void setStateIfMounted(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  // --- LÓGICA DE DATOS ---
  Future<void> _loadCategories() async {
    if (mounted) setStateIfMounted(() => _isLoadingCategories = true);
    try {
      final cats = await _reporteService.getCategorias();
      if (mounted) setStateIfMounted(() => _categoriasDisponibles = cats);
    } catch (e) {
      print("Error cargando categorías: $e");
    } finally {
      if (mounted) setStateIfMounted(() => _isLoadingCategories = false);
    }
  }

  Future<void> _cargarEstadosSolicitudes() async {
    if (!widget.isHistory || !mounted) return;
    if (_isLoadingSolicitudes) return;
    setStateIfMounted(() => _isLoadingSolicitudes = true);
    try {
      final List<SolicitudRevision> solicitudes =
          await _liderService.getMisSolicitudesRevision();
      final Map<int, String> nuevosEstados = {};
      for (var sol in solicitudes) {
        nuevosEstados[sol.idReporte] = sol.estado;
      }
      if (mounted) {
        setStateIfMounted(() => _estadoSolicitudes = nuevosEstados);
      }
    } catch (e) {
      print("Error cargando estados de solicitudes: $e");
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al cargar estado de solicitudes: $e'),
          backgroundColor: Colors.orange,
        ));
    } finally {
      if (mounted) setStateIfMounted(() => _isLoadingSolicitudes = false);
    }
  }

  Future<int> refreshData() async {
    _currentPage = 1;
    _hasMore = true;
    _reportes = [];
    if (mounted) setStateIfMounted(() => _isLoading = true);

    if (widget.isHistory) {
      await Future.wait([
        _fetchData(isRefresh: true),
        _cargarEstadosSolicitudes(),
      ]);
    } else {
      await _fetchData(isRefresh: true);
    }

    if (mounted) setStateIfMounted(() => _isLoading = false);
    return _totalFiltrado;
  }

  Future<void> _fetchData({bool isRefresh = false}) async {
    if (!mounted || (_isLoading && !isRefresh) || _isLoadingMore) return;

    if (!isRefresh) {
      setStateIfMounted(() => _isLoadingMore = true);
    } else {
      _errorMessage = null; // Limpiar error en refresh
    }

    try {
      PagedResult<dynamic> result;
      if (widget.isHistory) {
        String? estadoFilterApi;
        if (_filtroHistorialEstado != FiltroHistorialEstado.todos) {
          estadoFilterApi = _filtroHistorialEstado.name;
        }
        result = await _liderService.getReportesModerados(
          page: _currentPage,
          estado: estadoFilterApi,
          startDate: _startDate,
          endDate: _endDate,
        );
      } else {
        bool? prioritarioFilterApi =
            _filtroPendiente == FiltroPendiente.prioritarios ? true : null;
        bool? conApoyosFilterApi =
            _filtroPendiente == FiltroPendiente.conApoyos ? true : null;
        String? searchFilterApi = _searchTerm.isNotEmpty ? _searchTerm : null;
        result = await _liderService.getReportesPendientes(
            page: _currentPage,
            categoriaId: _filtroCategoriaId,
            prioritario: prioritarioFilterApi,
            conApoyos: conApoyosFilterApi,
            search: searchFilterApi,
            sortBy: _sortBy);
      }

      if (!mounted) return;
      setStateIfMounted(() {
        if (isRefresh) {
          _reportes = result.items;
        } else {
          _reportes.addAll(result.items);
        }
        _currentPage++;
        _hasMore = result.hasMore;
        _totalFiltrado = result.totalFiltrado;
        _isLoadingMore = false;
        _errorMessage = null;
      });
    } catch (e) {
      print(
          "Error fetching data (${widget.isHistory ? 'Hist' : 'Pend'} - Pág $_currentPage): $e");
      if (mounted) {
        setStateIfMounted(() {
          _isLoadingMore = false;
          _totalFiltrado = 0;
          if (isRefresh) {
            _errorMessage = e.toString().replaceFirst('Exception: ', '');
            _reportes = [];
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Error al cargar más: $e'),
                backgroundColor: Colors.orange));
            _hasMore = false;
          }
        });
      }
    }
  }

  // --- HANDLERS (CALLBACKS) ---
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        _hasMore &&
        !_isLoading &&
        !_isLoadingMore) {
      _fetchData();
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (mounted && _searchController.text != _searchTerm) {
        _searchTerm = _searchController.text;
        refreshData(); // Reiniciar búsqueda
      }
    });
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      setStateIfMounted(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      refreshData();
    }
  }

  Future<void> _handleSolicitarRevision(
      ReporteHistorialModerado reporte) async {
    if (_isRequestingReview[reporte.id] == true || _isLoadingSolicitudes)
      return;

    final motivo = await showDialog<String>(
      context: context,
      builder: (ctx) => DialogoSolicitudRevision(reporte: reporte),
    );

    if (motivo == null || motivo.isEmpty || !mounted) return;
    setStateIfMounted(() => _isRequestingReview[reporte.id] = true);
    try {
      final response =
          await _liderService.solicitarRevision(reporte.id, motivo);
      if (!mounted) return;
      final message = response['message'] ?? 'Error desconocido';
      final success = response['statusCode'] == 201;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: success
            ? Colors.green
            : (response['statusCode'] == 409 ? Colors.orange : Colors.red),
      ));
      if (success) {
        await _cargarEstadosSolicitudes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted)
        setStateIfMounted(() => _isRequestingReview.remove(reporte.id));
    }
  }

  Future<void> _handleNavigation(dynamic item) async {
    String routeName;
    int idToNavigate;
    if (widget.isHistory && item is ReporteHistorialModerado) {
      routeName = '/reporte_detalle';
      idToNavigate = item.id;
    } else if (!widget.isHistory && item is ReportePendiente) {
      routeName = '/verificacion_detalle';
      idToNavigate = item.id;
    } else {
      return;
    }
    final result =
        await Navigator.pushNamed(context, routeName, arguments: idToNavigate);
    if (result == true && mounted) {
      refreshData();
    }
  }

  void _handleIrAlOriginal(int? originalId) {
    if (originalId != null) {
      Navigator.pushNamed(context, '/reporte_detalle', arguments: originalId);
    }
  }

  // --- BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    super.build(context);

    // --- RENDERIZACIÓN PRINCIPAL ---
    if (_isLoading && _reportes.isEmpty) {
      return const EsqueletoListaActividad();
    }

    Widget listContent;
    if (_errorMessage != null && _reportes.isEmpty) {
      listContent = Center(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: $_errorMessage')));
    } else if (_reportes.isEmpty) {
      listContent = Center(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(widget.isHistory
                  ? 'No hay historial con estos filtros.'
                  : 'No hay reportes pendientes con estos filtros.')));
    } else {
      listContent = ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: _reportes.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _reportes.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                  child: _isLoadingMore
                      ? const CircularProgressIndicator()
                      : const SizedBox.shrink()),
            );
          }
          final item = _reportes[index];
          if (widget.isHistory && item is ReporteHistorialModerado) {
            final estadoSolicitudActual = _estadoSolicitudes[item.id];
            return TarjetaHistorialModerado(
              reporte: item,
              estadoSolicitud: estadoSolicitudActual,
              onTap: () => _handleNavigation(item),
              onSolicitarRevision: () => _handleSolicitarRevision(item),
              onIrAlOriginal: item.idReporteOriginal != null
                  ? () => _handleIrAlOriginal(item.idReporteOriginal)
                  : null,
            );
          } else if (!widget.isHistory && item is ReportePendiente) {
            return TarjetaVerificacion(
              reporte: item,
              onTap: () => _handleNavigation(item),
            );
          }
          return const SizedBox.shrink();
        },
      );
    }

    return Column(
      children: [
        // --- USAR LOS NUEVOS WIDGETS DE FILTRO ---
        if (!widget.isHistory)
          FiltrosPendientes(
            searchController: _searchController,
            sortBy: _sortBy,
            onSortToggle: () {
              setStateIfMounted(() {
                _sortBy = _sortBy == 'fecha_asc' ? 'fecha_desc' : 'fecha_asc';
              });
              refreshData();
            },
            filtroPendiente: _filtroPendiente,
            onFiltroPendienteChanged: (filtro) {
              setStateIfMounted(() => _filtroPendiente = filtro);
              refreshData();
            },
            isLoadingCategories: _isLoadingCategories,
            categoriasDisponibles: _categoriasDisponibles,
            filtroCategoriaId: _filtroCategoriaId,
            onCategoriaChanged: (value) {
              setStateIfMounted(() => _filtroCategoriaId = value);
              refreshData();
            },
          )
        else
          FiltrosHistorial(
            filtroHistorialEstado: _filtroHistorialEstado,
            onEstadoChanged: (filtro) {
              setStateIfMounted(() => _filtroHistorialEstado = filtro);
              refreshData();
            },
            startDate: _startDate,
            endDate: _endDate,
            onSelectDateRange: _selectDateRange,
          ),
        // --- FIN ---

        const Divider(height: 1, thickness: 1),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await refreshData();
            },
            child: listContent,
          ),
        ),
      ],
    );
  }
}
