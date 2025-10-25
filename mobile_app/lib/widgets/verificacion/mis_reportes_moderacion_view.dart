// lib/widgets/verificacion/mis_reportes_moderacion_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importar para formateo de fechas
import 'package:mobile_app/api/lider_service.dart';
import 'package:mobile_app/models/reporte_moderacion_model.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_lista_actividad.dart'; // Cambiado Esqueleto
import 'package:mobile_app/widgets/verificacion/tarjeta_moderacion_reporte.dart';

// Enums para filtros
enum FiltroTipoModeracion { todos, comentario, usuario }
// Eliminamos FiltroFechaModeracion enum

class MisReportesModeracionView extends StatefulWidget {
  // Key es necesaria para que el padre (verificacion_screen) llame a refreshData()
  const MisReportesModeracionView({required Key key}) : super(key: key);

  @override
  State<MisReportesModeracionView> createState() => MisReportesModeracionViewState();
}

class MisReportesModeracionViewState extends State<MisReportesModeracionView> with AutomaticKeepAliveClientMixin {
  final LiderService _liderService = LiderService();
  final ScrollController _scrollController = ScrollController();

  List<ReporteModeracion> _reportes = [];
  int _currentPageComentarios = 1;
  int _currentPageUsuarios = 1;
  bool _hasMoreComentarios = true;
  bool _hasMoreUsuarios = true;
  bool _isLoading = true; // Carga inicial o refresh
  bool _isLoadingMore = false; // Carga de paginación
  String? _errorMessage;
  // --- CORRECCIÓN: Añadido _totalFiltrado ---
  int _totalFiltrado = 0;

  // Filtros
  FiltroTipoModeracion _filtroTipo = FiltroTipoModeracion.todos;
  // --- CORRECCIÓN: Añadido _startDate y _endDate ---
  DateTime? _startDate;
  DateTime? _endDate;
  // Eliminamos _filtroFecha

  // Estado de carga para botón Quitar (ID_Tipo)
  final Map<String, bool> _deletingStatus = {};

  @override
  bool get wantKeepAlive => true; // Mantener estado de la pestaña

  @override
  void initState() {
    super.initState();
    // --- CORRECCIÓN: Inicializar fechas ---
    final now = DateTime.now();
    _startDate = now.subtract(const Duration(days: 7)); // Última semana por defecto
    _endDate = now;
    // --- FIN CORRECCIÓN ---
    refreshData(); // Carga inicial
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // --- CORRECCIÓN: Método público devuelve Future<int> ---
  Future<int> refreshData() async {
    _currentPageComentarios = 1;
    _currentPageUsuarios = 1;
    _hasMoreComentarios = true;
    _hasMoreUsuarios = true;
    // No limpiar _reportes aquí para evitar parpadeo
    await _fetchCombinedReports(isRefresh: true);
    return _totalFiltrado; // Devolver el total
  }
  // --- FIN CORRECCIÓN ---


  Future<void> _fetchCombinedReports({bool isRefresh = false}) async {
    if (!mounted || ( _isLoading && !isRefresh) || _isLoadingMore) return;

    setState(() {
      if (isRefresh) _isLoading = true;
      else _isLoadingMore = true;
      _errorMessage = null;
    });

    List<ReporteModeracion> nuevosReportes = [];
    int totalComentarios = 0;
    int totalUsuarios = 0;
    bool moreCom = isRefresh ? true : _hasMoreComentarios;
    bool moreUsr = isRefresh ? true : _hasMoreUsuarios;
    int pageCom = isRefresh ? 1 : _currentPageComentarios;
    int pageUsr = isRefresh ? 1 : _currentPageUsuarios;

    bool loadComentarios = (_filtroTipo == FiltroTipoModeracion.todos || _filtroTipo == FiltroTipoModeracion.comentario) && moreCom;
    bool loadUsuarios = (_filtroTipo == FiltroTipoModeracion.todos || _filtroTipo == FiltroTipoModeracion.usuario) && moreUsr;

    try {
        List<Future<PagedResult<ReporteModeracion>>> futures = [];
        if (loadComentarios) {
           futures.add(_liderService.getMisComentariosReportados(
             page: pageCom,
             startDate: _startDate, // Pasar fechas
             endDate: _endDate      // Pasar fechas
           ));
        }
        if (loadUsuarios) {
           futures.add(_liderService.getMisUsuariosReportados(
             page: pageUsr,
             startDate: _startDate, // Pasar fechas
             endDate: _endDate      // Pasar fechas
           ));
        }

       if (futures.isNotEmpty) {
           final results = await Future.wait(futures);
           int resultIndex = 0;
           if (loadComentarios) {
               final commentResult = results[resultIndex++];
               nuevosReportes.addAll(commentResult.items);
               moreCom = commentResult.hasMore;
               // --- CORRECCIÓN: Guardar total filtrado ---
               totalComentarios = commentResult.totalFiltrado;
           }
           if (loadUsuarios) {
               final userResult = results[resultIndex];
               nuevosReportes.addAll(userResult.items);
               moreUsr = userResult.hasMore;
               // --- CORRECCIÓN: Guardar total filtrado ---
               totalUsuarios = userResult.totalFiltrado;
           }
       } else {
           moreCom = false;
           moreUsr = false;
       }


      if (mounted) {
        setState(() {
          if (isRefresh) {
             _reportes = nuevosReportes; // Reemplazar
          } else {
             _reportes.addAll(nuevosReportes); // Añadir
          }

          if (loadComentarios && nuevosReportes.any((r) => r.tipo == TipoReporteModeracion.comentario)) _currentPageComentarios++;
          if (loadUsuarios && nuevosReportes.any((r) => r.tipo == TipoReporteModeracion.usuario)) _currentPageUsuarios++;

          _reportes.sort((a, b) => b.sortDate.compareTo(a.sortDate));

          _hasMoreComentarios = moreCom;
          _hasMoreUsuarios = moreUsr;
          // --- CORRECCIÓN: Calcular total filtrado combinado ---
          _totalFiltrado = totalComentarios + totalUsuarios;
          // --- FIN CORRECCIÓN ---
          _isLoading = false;
          _isLoadingMore = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
        print("Error fetching combined moderation reports: $e");
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isLoadingMore = false;
            // --- CORRECCIÓN: Resetear total ---
            _totalFiltrado = 0;
            // --- FIN CORRECCIÓN ---
            if (isRefresh) {
               _errorMessage = e.toString().replaceFirst('Exception: ', '');
               _reportes = [];
            } else {
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar más: $e'), backgroundColor: Colors.orange));
               _hasMoreComentarios = false;
               _hasMoreUsuarios = false;
            }
          });
        }
    }
  }

  void _onScroll() {
    bool hasMoreFiltered =
        (_filtroTipo == FiltroTipoModeracion.comentario && _hasMoreComentarios) ||
        (_filtroTipo == FiltroTipoModeracion.usuario && _hasMoreUsuarios) ||
        (_filtroTipo == FiltroTipoModeracion.todos && (_hasMoreComentarios || _hasMoreUsuarios));

    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9 &&
        hasMoreFiltered && !_isLoading && !_isLoadingMore) {
      _fetchCombinedReports();
    }
  }

  // --- CORRECCIÓN: Mostrar DateRangePicker ---
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
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      refreshData();
    }
  }
  // --- FIN CORRECCIÓN ---

  // Lógica Quitar Reporte (sin cambios funcionales)
  Future<void> _handleQuitarReporte(int moderacionReporteId, TipoReporteModeracion tipo) async {
    final String loadingKey = '${tipo.name}-$moderacionReporteId';
    if (_deletingStatus[loadingKey] == true) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quitar Reporte'),
        content: const Text('¿Estás seguro de que quieres eliminar este reporte de moderación pendiente? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(child: const Text('No'), onPressed: () => Navigator.pop(ctx, false)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, Quitar'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (mounted) setState(() => _deletingStatus[loadingKey] = true);

    Map<String, dynamic> response = {};
    try {
      response = await _liderService.eliminarReporteModeracion(moderacionReporteId, tipo);
      if (!mounted) return;

      final message = response['message'] ?? 'Error';
      final success = response['statusCode'] == 200;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ));

      if (success) {
        setState(() {
           _reportes.removeWhere((r) => r.id == moderacionReporteId && r.tipo == tipo);
           _deletingStatus.remove(loadingKey);
           // Decrementar contador localmente para UI instantánea
           if (_totalFiltrado > 0) _totalFiltrado--;
        });
        // Podríamos notificar al padre, pero el refresh global lo hará eventualmente
      } else {
         if (mounted) setState(() => _deletingStatus.remove(loadingKey));
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
         setState(() => _deletingStatus.remove(loadingKey));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Mantener estado de pestaña
    final DateFormat dateFormat = DateFormat('dd MMM', 'es_ES'); // Formateador para botón de fecha

    // --- UI de Filtros ---
    Widget buildFiltros() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        // --- CORRECCIÓN: Hacer scrollable horizontalmente ---
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
               // Filtro Tipo
               Wrap(
                 spacing: 8.0,
                 children: FiltroTipoModeracion.values.map((filtro) {
                   String label;
                   switch(filtro){
                      case FiltroTipoModeracion.comentario: label = 'Comentarios'; break;
                      case FiltroTipoModeracion.usuario: label = 'Usuarios'; break;
                      default: label = 'Todos'; break;
                   }
                   return ChoiceChip(
                     label: Text(label, style: const TextStyle(fontSize: 12)),
                     selected: _filtroTipo == filtro,
                     onSelected: (selected) {
                       if (selected) {
                         setState(() => _filtroTipo = filtro);
                         refreshData(); // Refrescar con nuevo filtro
                       }
                     },
                     visualDensity: VisualDensity.compact,
                   );
                 }).toList(),
               ),
               const SizedBox(width: 16), // Espacio antes de fecha
               // --- CORRECCIÓN: Botón para DateRangePicker ---
               TextButton.icon(
                 icon: const Icon(Icons.calendar_today, size: 16),
                 label: Text(
                   _startDate != null && _endDate != null
                     ? '${dateFormat.format(_startDate!)} - ${dateFormat.format(_endDate!)}'
                     : 'Seleccionar Fechas',
                   style: const TextStyle(fontSize: 12),
                 ),
                 onPressed: _selectDateRange,
                 style: TextButton.styleFrom(
                   visualDensity: VisualDensity.compact,
                   padding: const EdgeInsets.symmetric(horizontal: 8),
                 ),
               ),
               // --- FIN CORRECCIÓN ---
            ],
          ),
        ),
        // --- FIN CORRECCIÓN ---
      );
    }
    // --- Fin UI Filtros ---

    // --- Lógica Principal del Build ---
    if (_isLoading && _reportes.isEmpty) {
      return const EsqueletoListaActividad();
    }
    if (_errorMessage != null && _reportes.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(16), child: Text('Error: $_errorMessage')));
    }

    Widget listContent;
    if (_reportes.isEmpty) {
      listContent = const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('No hay reportes de moderación con estos filtros.')));
    } else {
      listContent = ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: _reportes.length + ((_hasMoreComentarios || _hasMoreUsuarios) ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _reportes.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: _isLoadingMore ? const CircularProgressIndicator() : const SizedBox.shrink()),
            );
          }
          final reporte = _reportes[index];
          final String loadingKey = '${reporte.tipo.name}-${reporte.id}';
          final bool isDeleting = _deletingStatus[loadingKey] ?? false;

          return TarjetaModeracionReporte(
            reporteModeracion: reporte,
            isDeleting: isDeleting,
            onTap: () {
              if (reporte.tipo == TipoReporteModeracion.comentario && reporte.idReporte != null) {
                Navigator.pushNamed(context, '/reporte_detalle', arguments: reporte.idReporte);
              }
            },
            onQuitar: reporte.estado == 'pendiente' ? _handleQuitarReporte : null,
          );
        },
      );
    }

    return Column(
      children: [
        buildFiltros(),
        const Divider(height: 1, thickness: 1),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async { await refreshData(); }, // Llama al método público
            child: listContent,
          ),
        ),
      ],
    );
  }
}