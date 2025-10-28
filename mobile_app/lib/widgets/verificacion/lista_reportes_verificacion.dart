import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_app/api/lider_service.dart';
import 'package:mobile_app/models/reporte_pendiente_model.dart';
import 'package:mobile_app/models/reporte_historial_moderado_model.dart';
import 'package:mobile_app/models/categoria_model.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_lista_actividad.dart';
import 'package:mobile_app/widgets/verificacion/tarjeta_verificacion.dart';
import 'package:mobile_app/widgets/verificacion/tarjeta_historial_moderado.dart';
import 'package:mobile_app/widgets/verificacion/filtros_pendientes.dart';
import 'package:mobile_app/widgets/verificacion/filtros_historial.dart';
import 'package:mobile_app/widgets/verificacion/dialogo_solicitud_revision.dart';

/// Enum para definir los filtros rápidos de la lista de pendientes.
enum FiltroPendiente { todos, prioritarios, conApoyos }

/// Enum para definir los filtros de estado de la lista de historial.
enum FiltroHistorialEstado { todos, verificado, rechazado, fusionado }

/// {@template lista_reportes_verificacion}
/// Widget reutilizable con estado que muestra una lista paginada de reportes
/// para el panel de verificación del líder.
///
/// Puede mostrar la lista de 'Pendientes' o la de 'Historial' basado en el flag [isHistory].
/// Maneja la carga de datos con paginación infinita, aplicación de filtros,
/// pull-to-refresh, y estados de carga/error/vacío.
/// {@endtemplate}
class ListaReportesVerificacion extends StatefulWidget {
  /// Si es `true`, muestra el historial de moderación. Si es `false`, muestra los pendientes.
  final bool isHistory;

  /// {@macro lista_reportes_verificacion}
  /// La [key] es importante para que [VerificacionScreen] pueda llamar a `refreshData`.
  const ListaReportesVerificacion(
      {required Key key, required this.isHistory})
      : super(key: key);

  @override
  ListaReportesVerificacionState createState() =>
      ListaReportesVerificacionState();
}

/// Estado para [ListaReportesVerificacion].
class ListaReportesVerificacionState extends State<ListaReportesVerificacion>
    with AutomaticKeepAliveClientMixin {
  final LiderService _liderService = LiderService();
  final ReporteService _reporteService = ReporteService(); // Para categorías
  final ScrollController _scrollController = ScrollController();

  /// Lista combinada de reportes (pendientes o historial).
  List<dynamic> _reportes = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = true; // Carga inicial
  bool _isLoadingMore = false; // Carga de paginación
  String? _errorMessage;
  /// Contador total de reportes que coinciden con los filtros (devuelto por la API).
  int _totalFiltrado = 0;

  // --- Estados de Filtro ---
  /// Controlador para el campo de búsqueda (solo pendientes).
  final TextEditingController _searchController = TextEditingController();
  /// Criterio de ordenación (solo pendientes).
  String _sortBy = 'fecha_desc'; // 'fecha_asc' o 'fecha_desc'
  /// Filtro rápido seleccionado (solo pendientes).
  FiltroPendiente _filtroPendiente = FiltroPendiente.todos;
  /// Estado de filtro seleccionado (solo historial).
  FiltroHistorialEstado _filtroHistorialEstado = FiltroHistorialEstado.todos;
  /// ID de categoría seleccionada (solo pendientes).
  int? _filtroCategoriaId;
  /// Fecha de inicio para filtro de rango (historial).
  DateTime? _startDate;
  /// Fecha de fin para filtro de rango (historial).
  DateTime? _endDate;
  /// Indica si se están cargando las categorías para el filtro.
  bool _isLoadingCategories = false;
  /// Lista de categorías disponibles para el filtro.
  List<Categoria> _categoriasDisponibles = [];
  /// Mapa para almacenar el estado de las solicitudes de revisión (solo historial).
  Map<int, String?> _estadoSolicitudes = {};

  @override
  void initState() {
    super.initState();
    _fetchData(isInitialLoad: true); // Carga inicial
    _scrollController.addListener(_onScroll); // Listener para infinite scroll
    if (!widget.isHistory) {
      _loadCategories(); // Carga categorías si es la lista de pendientes
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Mantiene el estado de la pestaña aunque se cambie a otra.
  @override
  bool get wantKeepAlive => true;

  /// Listener del scroll para cargar más datos al llegar al final.
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 && // Cerca del final
        !_isLoadingMore && // No está cargando ya
        _hasMore && // Aún hay más datos por cargar
        !_isLoading) // No está en carga inicial
    {
      _fetchData(); // Carga la siguiente página
    }
  }

  void setStateIfMounted(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  /// Carga las categorías para el filtro de pendientes.
  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
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

  /// Carga los datos de reportes (pendientes o historial) desde la API.
  ///
  /// [isInitialLoad]: Si es `true`, limpia la lista actual y resetea la página a 1.
  /// Retorna el número total de reportes filtrados devuelto por la API.
  Future<int> _fetchData({bool isInitialLoad = false}) async {
    if (isInitialLoad) {
      _currentPage = 1;
      _hasMore = true;
      _reportes = [];
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
          _totalFiltrado = 0;
        });
      }
    } else if (_isLoading || !_hasMore) {
      return _totalFiltrado; // Evita cargas múltiples o innecesarias
    }

    if (mounted) {
      setState(() => _isLoadingMore = true);
    }

    try {
      dynamic result;
      // Llama al servicio correspondiente según si es historial o pendientes
      if (widget.isHistory) {
        result = await _liderService.getReportesModerados(
          page: _currentPage,
          estado: _filtroHistorialEstado == FiltroHistorialEstado.todos
              ? null
              : _filtroHistorialEstado.name, // Envía el nombre del enum
          startDate: _startDate,
          endDate: _endDate,
        );
        // Si es historial, carga también el estado de las solicitudes de revisión
        if (_currentPage == 1) {
          await _cargarEstadosSolicitudes();
        }
      } else {
        result = await _liderService.getReportesPendientes(
          page: _currentPage,
          categoriaId: _filtroCategoriaId,
          prioritario: _filtroPendiente == FiltroPendiente.prioritarios,
          conApoyos: _filtroPendiente == FiltroPendiente.conApoyos,
          search: _searchController.text.trim(),
          sortBy: _sortBy,
        );
      }

      if (mounted) {
        setState(() {
          // Añade los nuevos items a la lista existente
          _reportes.addAll(result.items);
          _hasMore = result.hasMore;
          _currentPage++;
          _totalFiltrado = result.totalFiltrado; // Actualiza el total filtrado
          _isLoading = false;
          _isLoadingMore = false;
          _errorMessage = null;
        });
      }
      return _totalFiltrado; // Devuelve el total
    } catch (e) {
      debugPrint("Error fetching data (${widget.isHistory ? 'History' : 'Pending'}): $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
      return 0; // Devuelve 0 en caso de error
    }
  }

  /// Carga el estado de las solicitudes de revisión para los reportes del historial.
  Future<void> _cargarEstadosSolicitudes() async {
    if (!widget.isHistory) return;
    try {
      final solicitudes = await _liderService.getMisSolicitudesRevision();
      if (mounted) {
        final Map<int, String?> nuevosEstados = {};
        for (var sol in solicitudes) {
          nuevosEstados[sol.idReporte] = sol.estado;
        }
        setState(() => _estadoSolicitudes = nuevosEstados);
      }
    } catch (e) {
      debugPrint("Error cargando estados de solicitudes: $e");
      // No mostrar error al usuario, simplemente no se verá el estado
    }
  }

  /// Método público llamado por el widget padre ([VerificacionScreen]) para refrescar.
  /// Retorna el nuevo total de elementos filtrados.
  Future<int> refreshData() {
    return _fetchData(isInitialLoad: true);
  }

  /// Muestra el selector de rango de fechas y refresca los datos si se selecciona un rango.
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024), // Ajusta la fecha inicial según sea necesario
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        // Ajusta endDate para incluir todo el día
        _endDate = picked.end; //.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
      });
      refreshData();
    }
  }

  /// Maneja la navegación a la pantalla de detalle correspondiente.
  /// Si se regresa con `true`, refresca la lista actual.
  Future<void> _handleNavigation(int reporteId) async {
    final result = await Navigator.pushNamed(
      context,
      // Navega a la pantalla de verificación si es pendiente, si no, a la de detalle normal
      widget.isHistory ? '/reporte_detalle' : '/verificacion_detalle',
      arguments: reporteId,
    );
    // Si la pantalla de detalle/verificación devuelve true, refrescar lista
    if (result == true && mounted) {
      refreshData();
    }
  }

  /// Muestra el diálogo para solicitar revisión y envía la solicitud si se confirma.
  Future<void> _handleSolicitarRevision(ReporteHistorialModerado reporte) async {
    final motivo = await showDialog<String>(
      context: context,
      builder: (ctx) => DialogoSolicitudRevision(reporte: reporte),
    );

    if (motivo != null && motivo.isNotEmpty) {
      // Mostrar indicador de carga temporalmente
      setState(() => _estadoSolicitudes[reporte.id] = 'enviando');

      final response = await _liderService.solicitarRevision(reporte.id, motivo);

      if (!mounted) return;

      final message = response['message'] ?? 'Error desconocido';
      final success = response['statusCode'] == 201;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ));

      if (success) {
        // Actualiza el estado localmente para reflejar el cambio inmediatamente
        setState(() => _estadoSolicitudes[reporte.id] = 'pendiente');
      } else {
        // Revierte el estado si falló
        setState(() => _estadoSolicitudes.remove(reporte.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necesario para AutomaticKeepAliveClientMixin

    Widget listContent;

    if (_isLoading && _reportes.isEmpty) {
      listContent = const EsqueletoListaActividad(); // Usar un esqueleto adecuado
    } else if (_errorMessage != null) {
      listContent = ListView(
          physics: const AlwaysScrollableScrollPhysics(), // Permite refresh en error
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Center(child: Text('Error: $_errorMessage')),
            Center(child: TextButton(onPressed: () => refreshData(), child: const Text('Reintentar')))
          ]);
    } else if (_reportes.isEmpty) {
      listContent = ListView(
          physics: const AlwaysScrollableScrollPhysics(), // Permite refresh en vacío
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('No hay reportes que coincidan con los filtros.', textAlign: TextAlign.center)))
          ]);
    } else {
      // Construye la lista de reportes (pendientes o historial)
      listContent = ListView.builder(
        controller: _scrollController,
        // Añade padding inferior para que el último item no quede pegado al fondo
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: _reportes.length + (_hasMore ? 1 : 0), // +1 para el indicador de carga
        itemBuilder: (context, index) {
          // Si es el último item y hay más por cargar, muestra el indicador
          if (index == _reportes.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                  child: _isLoadingMore
                      ? const CircularProgressIndicator()
                      : const SizedBox.shrink()),
            );
          }

          // Renderiza la tarjeta correspondiente
          final item = _reportes[index];
          if (widget.isHistory) {
            final reporteHistorial = item as ReporteHistorialModerado;
            return TarjetaHistorialModerado(
              reporte: reporteHistorial,
              estadoSolicitud: _estadoSolicitudes[reporteHistorial.id],
              onTap: () => _handleNavigation(reporteHistorial.id),
              onSolicitarRevision: () => _handleSolicitarRevision(reporteHistorial),
              onIrAlOriginal: reporteHistorial.idReporteOriginal != null
                  ? () => _handleNavigation(reporteHistorial.idReporteOriginal!)
                  : null,
            );
          } else {
            final reportePendiente = item as ReportePendiente;
            return TarjetaVerificacion(
              reporte: reportePendiente,
              onTap: () => _handleNavigation(reportePendiente.id),
            );
          }
        },
      );
    }

    // Estructura final con filtros y lista
    return Column(
      children: [
        // Muestra los filtros correspondientes
        if (!widget.isHistory)
          FiltrosPendientes(
            searchController: _searchController,
            sortBy: _sortBy,
            onSortToggle: () {
              setStateIfMounted(() {
                _sortBy = _sortBy == 'fecha_asc' ? 'fecha_desc' : 'fecha_asc';
              });
              refreshData(); // Refresca con el nuevo orden
            },
            filtroPendiente: _filtroPendiente,
            onFiltroPendienteChanged: (filtro) {
              setStateIfMounted(() => _filtroPendiente = filtro);
              refreshData(); // Refresca con el nuevo filtro rápido
            },
            isLoadingCategories: _isLoadingCategories,
            categoriasDisponibles: _categoriasDisponibles,
            filtroCategoriaId: _filtroCategoriaId,
            onCategoriaChanged: (value) {
              setStateIfMounted(() => _filtroCategoriaId = value);
              refreshData(); // Refresca con la nueva categoría
            },
          )
        else
          FiltrosHistorial(
            filtroHistorialEstado: _filtroHistorialEstado,
            onEstadoChanged: (filtro) {
              setStateIfMounted(() => _filtroHistorialEstado = filtro);
              refreshData(); // Refresca con el nuevo estado
            },
            startDate: _startDate,
            endDate: _endDate,
            onSelectDateRange: _selectDateRange, // Abre el selector de fechas
          ),

        const Divider(height: 1, thickness: 1),
        Expanded(
          child: RefreshIndicator(
            // Permite refrescar arrastrando hacia abajo
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