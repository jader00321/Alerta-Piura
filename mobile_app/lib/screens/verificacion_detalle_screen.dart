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

class VerificacionDetalleScreen extends StatefulWidget {
  final int reporteId;
  const VerificacionDetalleScreen({super.key, required this.reporteId});

  @override
  State<VerificacionDetalleScreen> createState() =>
      _VerificacionDetalleScreenState();
}

class _VerificacionDetalleScreenState extends State<VerificacionDetalleScreen> {
  final ReporteService _reporteService = ReporteService();
  final LiderService _liderService = LiderService();

  ReporteDetallado? _reporte;
  bool _isLoadingReporte = true;
  String? _errorReporte;
  bool _isLoadingAction = false;

  @override
  void initState() {
    super.initState();
    _loadReporteData();
  }

  void setStateIfMounted(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

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

  Future<void> _iniciarEdicion() async {
    if (_reporte == null || _isLoadingAction) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PantallaEditarReporteLider(reporteInicial: _reporte!)),
    );
    if (result == true && mounted) {
      _loadReporteData();
    }
  }

  Future<void> _iniciarFusion() async {
    if (_reporte == null || _isLoadingAction) return;

    if (!mounted) return;
    final reporteOriginalId = await Navigator.push<int>(
      context,
      MaterialPageRoute(
          builder: (context) => const PantallaBuscarReporteOriginal()),
    );

    if (reporteOriginalId == null || !mounted) return;

    ReporteDetallado? reporteOriginal;
    String originalIdentifier = '#$reporteOriginalId';
    setStateIfMounted(() => _isLoadingAction = true);
    try {
      reporteOriginal = await _reporteService.getReporteById(reporteOriginalId);
      originalIdentifier =
          '"${reporteOriginal.titulo}" (${reporteOriginal.codigoReporte ?? '#$reporteOriginalId'})';
    } catch (e) {
      debugPrint("Error obteniendo detalles del original: $e");
    } finally {
      if (mounted) {
        setStateIfMounted(() => _isLoadingAction = false);
      }
    }
    if (!mounted) return;

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

    setStateIfMounted(() => _isLoadingAction = true);
    Map<String, dynamic> response = {};
    try {
      response = await _liderService.fusionarReporte(
          widget.reporteId, reporteOriginalId);
    } catch (e) {
      response = {
        'statusCode': 500,
        'message': 'Error de conexión al fusionar.'
      };
    }

    if (!mounted) return;

    setStateIfMounted(() => _isLoadingAction = false);
    final message = response['message'] ?? 'Error desconocido';
    final success = response['statusCode'] == 200;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green : Colors.red,
    ));
    if (success) {
      Navigator.pop(context, true);
    }
  }

  void _irAlChat() {
    if (_reporte == null) return;
    Navigator.pushNamed(context, '/chat', arguments: {
      'reporteId': _reporte!.id,
      'reporteTitulo': _reporte!.titulo,
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ReporteDetallado>(
      future: _reporte == null
          ? _reporteService.getReporteById(widget.reporteId)
          : Future.value(_reporte!),
      builder: (context, snapshot) {
        if ((snapshot.connectionState == ConnectionState.waiting &&
                _reporte == null) ||
            _isLoadingReporte) {
          return Scaffold(
            appBar: AppBar(title: const Text('Cargando...')),
            body: const EsqueletoReporteDetalle(),
          );
        }

        if (snapshot.hasError || _errorReporte != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                  'Error al cargar el reporte: ${_errorReporte ?? snapshot.error}'),
            )),
            floatingActionButton: FloatingActionButton(
              onPressed: _loadReporteData,
              tooltip: 'Reintentar',
              child: const Icon(Icons.refresh),
            ),
          );
        }

        if (snapshot.hasData && _reporte == null) {
          _reporte = snapshot.data;
        }

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

        return Scaffold(
          appBar: CabezalDetalleVerificacion.buildAppBar(
            context,
            isLoadingAction: _isLoadingAction,
            onEditar: _iniciarEdicion,
            onChat: _irAlChat,
            reporteEstado: _reporte!.estado,
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
