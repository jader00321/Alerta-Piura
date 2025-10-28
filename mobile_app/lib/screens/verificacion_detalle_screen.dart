import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_app/api/lider_service.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:mobile_app/models/reporte_detallado_model.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_reporte_detalle.dart';
import 'package:mobile_app/widgets/verificacion/layout_detalle_verificacion.dart';
import 'package:mobile_app/widgets/verificacion/cabezal_detalle_verificacion.dart';
import 'package:mobile_app/widgets/verificacion/acciones_moderacion.dart';
import 'package:mobile_app/screens/pantalla_editar_reporte_lider.dart';
import 'package:mobile_app/screens/pantalla_buscar_reporte_original.dart';

/// {@template verificacion_detalle_screen}
/// Pantalla utilizada por los Líderes Vecinales para ver los detalles
/// completos de un reporte pendiente y realizar acciones de moderación.
///
/// Muestra la información del reporte usando [LayoutDetalleVerificacion].
/// Proporciona acciones (Aprobar, Rechazar, Fusionar) a través de [AccionesModeracion].
/// Permite navegar a [PantallaEditarReporteLider] y [PantallaBuscarReporteOriginal].
/// {@endtemplate}
class VerificacionDetalleScreen extends StatefulWidget {
  /// El ID del reporte pendiente a verificar.
  final int reporteId;

  /// {@macro verificacion_detalle_screen}
  const VerificacionDetalleScreen({super.key, required this.reporteId});

  @override
  State<VerificacionDetalleScreen> createState() =>
      _VerificacionDetalleScreenState();
}

/// Estado para [VerificacionDetalleScreen].
///
/// Maneja la carga de los detalles del reporte, el estado de carga de las acciones
/// y la lógica para aprobar, rechazar, editar, fusionar y chatear.
class _VerificacionDetalleScreenState
    extends State<VerificacionDetalleScreen> {
  final ReporteService _reporteService = ReporteService();
  final LiderService _liderService = LiderService();

  /// Los datos detallados del reporte cargado.
  ReporteDetallado? _reporte;
  /// Indica si se están cargando los datos iniciales del reporte.
  bool _isLoadingReporte = true;
  /// Mensaje de error si la carga inicial falla.
  String? _errorReporte;
  /// Indica si se está procesando una acción de moderación (Aprobar, Rechazar, Fusionar).
  bool _isLoadingAction = false;

  @override
  void initState() {
    super.initState();
    _loadReporteData();
  }

  /// Helper para llamar a setState solo si el widget está montado.
  void setStateIfMounted(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  /// Carga o recarga los detalles completos del reporte desde [ReporteService].
  Future<void> _loadReporteData() async {
    if (!mounted) return;
    setStateIfMounted(() {
      _isLoadingReporte = true;
      _errorReporte = null;
    });
    try {
      final reporteData =
          await _reporteService.getReporteById(widget.reporteId);
      if (mounted) {
        setStateIfMounted(() {
          _reporte = reporteData;
          _isLoadingReporte = false;
        });
      }
    } catch (e) {
      debugPrint("Error cargando detalle para verificación: $e");
      if (mounted) {
        setStateIfMounted(() {
          _errorReporte = e.toString().replaceFirst('Exception: ', '');
          _isLoadingReporte = false;
        });
      }
    }
  }

  /// Ejecuta la acción de aprobar o rechazar el reporte.
  ///
  /// Llama a [LiderService.aprobarReporte] o [LiderService.rechazarReporte].
  /// Muestra un [SnackBar] y cierra la pantalla si tiene éxito.
  ///
  /// [aprobar]: `true` para aprobar, `false` para rechazar.
  Future<void> _moderarReporte(bool aprobar) async {
    if (_isLoadingAction || _reporte == null) return;
    setStateIfMounted(() => _isLoadingAction = true);
    Map<String, dynamic> response = {};
    String actionName = aprobar ? 'aprobar' : 'rechazar';
    try {
      if (aprobar) {
        response = await _liderService.aprobarReporte(widget.reporteId);
      } else {
        response = await _liderService.rechazarReporte(widget.reporteId);
      }

      if (!mounted) return;

      final message = response['message'] ?? 'Error desconocido';
      final success = response['statusCode'] == 200;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
      if (success) {
        // Devuelve true para indicar que hubo un cambio y la lista anterior debe refrescar
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al $actionName: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) {
        setStateIfMounted(() => _isLoadingAction = false);
      }
    }
  }

  /// Navega a [PantallaEditarReporteLider] para editar el reporte actual.
  /// Si la edición es exitosa, recarga los datos del reporte.
  Future<void> _iniciarEdicion() async {
    if (_reporte == null || _isLoadingAction) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PantallaEditarReporteLider(reporteInicial: _reporte!)),
    );
    // Si la pantalla de edición devuelve true, recarga los datos
    if (result == true && mounted) {
      _loadReporteData();
    }
  }

  /// Inicia el flujo de fusión de reportes.
  ///
  /// 1. Navega a [PantallaBuscarReporteOriginal] para seleccionar el reporte base.
  /// 2. Muestra un diálogo de confirmación.
  /// 3. Llama a [LiderService.fusionarReporte].
  /// 4. Cierra la pantalla si tiene éxito.
  Future<void> _iniciarFusion() async {
    if (_reporte == null || _isLoadingAction) return;

    if (!mounted) return;
    // 1. Abrir pantalla de búsqueda y esperar el ID del reporte original
    final reporteOriginalId = await Navigator.push<int>(
      context,
      MaterialPageRoute(
          builder: (context) => const PantallaBuscarReporteOriginal()),
    );

    if (reporteOriginalId == null || !mounted) return;

    // (Opcional) Cargar detalles del original para mostrar en confirmación
    ReporteDetallado? reporteOriginal;
    String originalIdentifier = '#$reporteOriginalId';
    setStateIfMounted(() => _isLoadingAction = true); // Bloquear UI mientras carga
    try {
      reporteOriginal = await _reporteService.getReporteById(reporteOriginalId);
      originalIdentifier =
          '"${reporteOriginal.titulo}" (${reporteOriginal.codigoReporte ?? '#$reporteOriginalId'})';
    } catch (e) {
      debugPrint("Error obteniendo detalles del original: $e");
      // Continuar aunque no se carguen los detalles
    } finally {
      if (mounted) {
        setStateIfMounted(() => _isLoadingAction = false);
      }
    }
    if (!mounted) return;

    // 2. Mostrar diálogo de confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Fusión'),
        content: Text(
            '¿Fusionar "${_reporte!.titulo}" (${_reporte!.codigoReporte ?? '#${widget.reporteId}'}) con el reporte original $originalIdentifier?'),
        actions: [
          TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(ctx, false)),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text('Sí, Fusionar'),
              onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    );
    if (confirm != true) return;

    // 3. Llamar a la API para fusionar
    setStateIfMounted(() => _isLoadingAction = true);
    Map<String, dynamic> response = {};
    try {
      response =
          await _liderService.fusionarReporte(widget.reporteId, reporteOriginalId);
    } catch (e) {
      response = {'statusCode': 500, 'message': 'Error de conexión al fusionar.'};
    }

    if (!mounted) return;

    // 4. Procesar resultado
    setStateIfMounted(() => _isLoadingAction = false);
    final message = response['message'] ?? 'Error desconocido';
    final success = response['statusCode'] == 200;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green : Colors.red,
    ));
    if (success) {
      Navigator.pop(context, true); // Indicar éxito a la pantalla anterior
    }
  }

  /// Navega a la pantalla de chat [ChatScreen] para el reporte actual.
  void _irAlChat() {
    if (_reporte == null) return;
    Navigator.pushNamed(context, '/chat', arguments: {
      'reporteId': _reporte!.id,
      'reporteTitulo': _reporte!.titulo,
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usa FutureBuilder para manejar los estados de carga/error iniciales
    return FutureBuilder<ReporteDetallado>(
      // Usa el reporte ya cargado si existe, si no, inicia la carga
      future: _reporte == null
          ? _reporteService.getReporteById(widget.reporteId)
          : Future.value(_reporte!),
      builder: (context, snapshot) {
        // Estado de carga inicial
        if ((snapshot.connectionState == ConnectionState.waiting &&
                _reporte == null) ||
            _isLoadingReporte) {
          return Scaffold(
            appBar: AppBar(title: const Text('Cargando...')),
            body: const EsqueletoReporteDetalle(),
          );
        }

        // Estado de error
        if (snapshot.hasError || _errorReporte != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  Text('Error al cargar el reporte: ${_errorReporte ?? snapshot.error}'),
            )),
            floatingActionButton: FloatingActionButton(
              onPressed: _loadReporteData, // Botón para reintentar
              tooltip: 'Reintentar',
              child: const Icon(Icons.refresh),
            ),
          );
        }

        // Si hay datos pero _reporte es null (poco probable aquí), actualizar _reporte
        if (snapshot.hasData && _reporte == null) {
          _reporte = snapshot.data;
        }

        // Si _reporte sigue siendo null después de todo, mostrar error genérico
        if (_reporte == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('No se pudo cargar el reporte.')),
            floatingActionButton: FloatingActionButton(
              onPressed: _loadReporteData,
              tooltip: 'Reintentar',
              child: const Icon(Icons.refresh),
            ),
          );
        }

        // Estado con datos: Construir la UI principal
        return Scaffold(
          appBar: CabezalDetalleVerificacion.buildAppBar(
            context,
            isLoadingAction: _isLoadingAction,
            onEditar: _iniciarEdicion,
            onChat: _irAlChat,
            reporteEstado: _reporte!.estado, // Pasa el estado actual
          ),
          body: RefreshIndicator(
            onRefresh: _loadReporteData,
            child: LayoutDetalleVerificacion(
              reporte: _reporte!,
            ),
          ),
          bottomNavigationBar: (_reporte?.estado == 'pendiente_verificacion')
              ? AccionesModeracion(
                  isLoading: _isLoadingAction,
                  onModerar: _moderarReporte,
                  onFusionar: _iniciarFusion,
                )
              : null,
        );
      },
    );
  }
}