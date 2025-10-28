import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/api/lider_service.dart';
import 'package:mobile_app/models/reporte_moderacion_model.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_lista_actividad.dart';
import 'package:mobile_app/widgets/verificacion/tarjeta_moderacion_reporte.dart';

/// Enum para los filtros de tipo en esta vista.
enum FiltroTipoModeracion { todos, comentario, usuario }

/// {@template mis_reportes_moderacion_view}
/// Widget con estado que muestra la lista de reportes de moderación
/// (sobre comentarios o usuarios) creados por el líder actual.
///
/// Se utiliza como una de las pestañas en [VerificacionScreen].
/// Maneja la carga paginada combinada de ambos tipos de reportes,
/// filtros por tipo y fecha, scroll infinito y la acción de "Quitar"
/// un reporte de moderación pendiente.
/// {@endtemplate}
class MisReportesModeracionView extends StatefulWidget {
  /// La [key] es necesaria para que [VerificacionScreen] pueda llamar a `refreshData`.
  const MisReportesModeracionView({required Key key}) : super(key: key);

  @override
  State<MisReportesModeracionView> createState() =>
      MisReportesModeracionViewState();
}

/// Estado para [MisReportesModeracionView].
class MisReportesModeracionViewState extends State<MisReportesModeracionView>
    with AutomaticKeepAliveClientMixin {
  final LiderService _liderService = LiderService();
  final ScrollController _scrollController = ScrollController();

  /// Lista combinada de reportes de moderación (comentarios y usuarios).
  List<ReporteModeracion> _reportes = [];
  /// Página actual para cargar comentarios reportados.
  int _currentPageComentarios = 1;
  /// Página actual para cargar usuarios reportados.
  int _currentPageUsuarios = 1;
  /// Indica si hay más comentarios por cargar.
  bool _hasMoreComentarios = true;
  /// Indica si hay más usuarios por cargar.
  bool _hasMoreUsuarios = true;
  /// Indica si se está realizando la carga inicial.
  bool _isLoading = true;
  /// Indica si se está cargando la siguiente página.
  bool _isLoadingMore = false;
  /// Mensaje de error a mostrar.
  String? _errorMessage;
  /// Filtro de tipo actualmente seleccionado.
  FiltroTipoModeracion _filtroTipo = FiltroTipoModeracion.todos;
  /// Fecha de inicio para el filtro de rango.
  DateTime? _startDate;
  /// Fecha de fin para el filtro de rango.
  DateTime? _endDate;
  /// Mapa para rastrear el estado de eliminación de reportes de moderación.
  final Map<String, bool> _deletingStatus = {};

  @override
  void initState() {
    super.initState();
    _fetchCombinedReports(isInitialLoad: true); // Carga inicial
    _scrollController.addListener(_onScroll); // Listener para scroll infinito
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Mantiene el estado de la pestaña.
  @override
  bool get wantKeepAlive => true;

  /// Listener del scroll para cargar más datos al llegar al final.
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        (_hasMoreComentarios || _hasMoreUsuarios) && // Si hay más de alguno
        !_isLoading) {
      _fetchCombinedReports(); // Carga la siguiente página combinada
    }
  }

  /// Carga los datos combinados de comentarios y usuarios reportados, paginados.
  ///
  /// [isInitialLoad]: Si es `true`, resetea el estado y carga la primera página.
  /// Retorna el número total de reportes cargados.
  Future<int> _fetchCombinedReports({bool isInitialLoad = false}) async {
    if (isInitialLoad) {
      _currentPageComentarios = 1;
      _currentPageUsuarios = 1;
      _hasMoreComentarios = true;
      _hasMoreUsuarios = true;
      _reportes = [];
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }
    } else if (_isLoading || !(_hasMoreComentarios || _hasMoreUsuarios)) {
      return _reportes.length; // Evita cargas innecesarias
    }

    if (mounted) {
      setState(() => _isLoadingMore = true);
    }

    try {
      List<Future<PagedResult<ReporteModeracion>>> futures = [];

      // Añade la llamada para comentarios si aplica según el filtro y si hay más
      if ((_filtroTipo == FiltroTipoModeracion.todos ||
              _filtroTipo == FiltroTipoModeracion.comentario) &&
          _hasMoreComentarios) {
        futures.add(_liderService.getMisComentariosReportados(
          page: _currentPageComentarios,
          startDate: _startDate,
          endDate: _endDate,
        ));
      }

      // Añade la llamada para usuarios si aplica según el filtro y si hay más
      if ((_filtroTipo == FiltroTipoModeracion.todos ||
              _filtroTipo == FiltroTipoModeracion.usuario) &&
          _hasMoreUsuarios) {
        futures.add(_liderService.getMisUsuariosReportados(
          page: _currentPageUsuarios,
          startDate: _startDate,
          endDate: _endDate,
        ));
      }

      if (futures.isEmpty) {
        // Si no se necesita cargar nada más
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isLoadingMore = false;
          });
        }
        return _reportes.length;
      }

      // Espera a que ambas (o una) llamadas terminen
      final results = await Future.wait(futures);

      List<ReporteModeracion> nuevosReportes = [];
      int resultIndex = 0;

      // Procesa resultado de comentarios
      if ((_filtroTipo == FiltroTipoModeracion.todos ||
              _filtroTipo == FiltroTipoModeracion.comentario) &&
          _hasMoreComentarios) {
        final commentResult = results[resultIndex++];
        nuevosReportes.addAll(commentResult.items);
        _hasMoreComentarios = commentResult.hasMore;
        if (commentResult.hasMore) _currentPageComentarios++;
      }

      // Procesa resultado de usuarios
      if ((_filtroTipo == FiltroTipoModeracion.todos ||
              _filtroTipo == FiltroTipoModeracion.usuario) &&
          _hasMoreUsuarios) {
        final userResult = results[resultIndex];
        nuevosReportes.addAll(userResult.items);
        _hasMoreUsuarios = userResult.hasMore;
        if (userResult.hasMore) _currentPageUsuarios++;
      }

      // Ordena los nuevos reportes combinados por fecha descendente
      nuevosReportes.sort((a, b) => b.sortDate.compareTo(a.sortDate));

      if (mounted) {
        setState(() {
          _reportes.addAll(nuevosReportes); // Añade los nuevos reportes ordenados
          _isLoading = false;
          _isLoadingMore = false;
          _errorMessage = null;
        });
      }
      // Devuelve el total actual (no devuelto por API combinada, así que usamos length)
      return _reportes.length;
    } catch (e) {
      debugPrint("Error fetching combined moderation reports: $e");
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

  /// Método público para refrescar los datos desde cero.
  /// Retorna el nuevo total de elementos.
  Future<int> refreshData() {
    return _fetchCombinedReports(isInitialLoad: true);
  }

  /// Muestra el selector de rango de fechas y refresca los datos si se selecciona un rango.
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      refreshData();
    }
  }

  /// Maneja la acción de "Quitar" un reporte de moderación pendiente.
  Future<void> _handleQuitarReporte(
      int moderacionReporteId, TipoReporteModeracion tipo) async {
    final String loadingKey = '${tipo.name}-$moderacionReporteId';
    if (_deletingStatus[loadingKey] == true) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quitar Reporte de Moderación'),
        content: const Text(
            '¿Estás seguro de que quieres cancelar este reporte de moderación? El contenido seguirá siendo visible.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí, Quitar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _deletingStatus[loadingKey] = true);
      final response =
          await _liderService.eliminarReporteModeracion(moderacionReporteId, tipo);
      if (mounted) {
        final success = response['statusCode'] == 200;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['message'] ?? 'Acción completada.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ));
        if (success) {
          // Elimina el item de la lista localmente para UI instantánea
          setState(() {
            _reportes.removeWhere((r) => r.id == moderacionReporteId && r.tipo == tipo);
          });
          // Podrías llamar a refreshData() pero quitar localmente es más rápido
        }
        setState(() => _deletingStatus.remove(loadingKey));
      }
    }
  }

  /// Construye la fila de filtros (Tipo y Fecha).
  Widget buildFiltros() {
    final DateFormat dateFormat = DateFormat('dd MMM', 'es_ES');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            /// Chips para filtrar por tipo.
            Wrap(
              spacing: 8.0,
              children: FiltroTipoModeracion.values.map((filtro) {
                String label;
                switch (filtro) {
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
                      refreshData(); // Recarga con el nuevo filtro
                    }
                  },
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
            const SizedBox(width: 16),
            /// Botón para seleccionar rango de fechas.
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necesario para AutomaticKeepAliveClientMixin

    Widget listContent;

    if (_isLoading && _reportes.isEmpty) {
      listContent = const EsqueletoListaActividad(); // Usar esqueleto adecuado
    } else if (_errorMessage != null) {
      listContent = ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Center(child: Text('Error: $_errorMessage')),
            Center(child: TextButton(onPressed: () => refreshData(), child: const Text('Reintentar')))
          ]);
    } else if (_reportes.isEmpty) {
      listContent = ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            const Center(
                child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                  'No hay reportes de moderación que coincidan con los filtros.',
                  textAlign: TextAlign.center),
            ))
          ]);
    } else {
      // Construye la lista de tarjetas de moderación.
      listContent = ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 80), // Espacio para FAB/scroll
        itemCount: _reportes.length +
            ((_hasMoreComentarios || _hasMoreUsuarios)
                ? 1
                : 0), // +1 para indicador de carga
        itemBuilder: (context, index) {
          // Muestra indicador de carga al final si hay más páginas
          if (index == _reportes.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                  child: _isLoadingMore
                      ? const CircularProgressIndicator()
                      : const SizedBox.shrink()),
            );
          }
          final reporte = _reportes[index];
          // Clave única para el estado de eliminación
          final String loadingKey = '${reporte.tipo.name}-${reporte.id}';
          final bool isDeleting = _deletingStatus[loadingKey] ?? false;

          // Renderiza la tarjeta de moderación
          return TarjetaModeracionReporte(
            reporteModeracion: reporte,
            isDeleting: isDeleting,
            onTap: () {
              // Navega al detalle del reporte si es un reporte de comentario
              if (reporte.tipo == TipoReporteModeracion.comentario &&
                  reporte.idReporte != null) {
                Navigator.pushNamed(context, '/reporte_detalle',
                    arguments: reporte.idReporte);
              }
              // Podría añadirse navegación al perfil de usuario si es reporte de usuario
            },
            // Permite quitar solo si está pendiente
            onQuitar: reporte.estado == 'pendiente' ? _handleQuitarReporte : null,
          );
        },
      );
    }

    // Estructura final con filtros y lista
    return Column(
      children: [
        buildFiltros(), // Muestra la fila de filtros
        const Divider(height: 1, thickness: 1),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await refreshData();
            }, // Permite pull-to-refresh
            child: listContent,
          ),
        ),
      ],
    );
  }
}