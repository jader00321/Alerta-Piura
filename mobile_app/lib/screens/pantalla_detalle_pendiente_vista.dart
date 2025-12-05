import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:mobile_app/models/reporte_detallado_model.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_reporte_detalle.dart';
import 'package:mobile_app/widgets/reporte_detalle/reporte_header.dart';
import 'package:mobile_app/widgets/verificacion/mapa_verificacion.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/auth_provider.dart';

/// {@template pantalla_detalle_pendiente_vista}
/// Vista detallada para un reporte en estado 'pendiente_verificacion'.
///
/// Lógica de Sincronización:
/// - Recibe estado inicial vía argumentos.
/// - Devuelve estado final al hacer Pop.
/// {@endtemplate}
class PantallaDetallePendienteVista extends StatefulWidget {
  final int reporteId;

  const PantallaDetallePendienteVista({super.key, required this.reporteId});

  @override
  State<PantallaDetallePendienteVista> createState() =>
      _PantallaDetallePendienteVistaState();
}

class _PantallaDetallePendienteVistaState
    extends State<PantallaDetallePendienteVista> {
  final ReporteService _reporteService = ReporteService();

  late Future<ReporteDetallado> _reporteFuture;
  late int _idReporteFinal;
  bool _isProcessing = false;

  // Estado local para sincronización manual e inmediata
  bool? _isJoinedOverride; 
  int? _apoyosOverride; // Para mantener el conteo actualizado localmente

  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      // 1. LEER ARGUMENTOS: Intentar leer lo que manda PantallaCercaDeTi
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args is Map) {
        _idReporteFinal = args['id'];
        _isJoinedOverride = args['isJoined']; // Estado inicial del botón
        _apoyosOverride = args['apoyosCount']; // Conteo inicial
      } else {
        _idReporteFinal = widget.reporteId;
      }
      
      _loadReporte();
      _isInit = true;
    }
  }

  void _loadReporte() {
    setState(() {
      _reporteFuture = _reporteService.getReporteById(_idReporteFinal);
    });
  }

  /// Función para cerrar la pantalla devolviendo los datos actualizados
  void _returnWithData() {
    // Si tenemos datos overrides (porque interactuamos), los devolvemos.
    // Si no, devolvemos null y la lista anterior no hará nada o recargará.
    if (_isJoinedOverride != null && _apoyosOverride != null) {
      Navigator.pop(context, {
        'isJoined': _isJoinedOverride,
        'apoyosCount': _apoyosOverride
      });
    } else {
      Navigator.pop(context);
    }
  }

  Future<bool> _confirmAction(String title, String content, String confirmText, Color color) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
             onPressed: () => Navigator.pop(context, false),
             child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
            child: Text(confirmText),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _handleJoinReport(int reporteId) async {
    final confirm = await _confirmAction('¿Unirse?', 'Validarás este reporte.', 'Unirme', Colors.green);
    if (!confirm) return;

    setState(() => _isProcessing = true);
    try {
      final response = await _reporteService.unirseReportePendiente(reporteId);
      if (!mounted) return;

      final success = response['statusCode'] == 201 ||
          (response['statusCode'] == 200 && (response['message']?.contains('unido') ?? false));

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response['message'] ?? 'Acción realizada'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));

      if (success) {
        setState(() {
          // Actualización Local Inmediata
          _isJoinedOverride = true;
          // Usamos el conteo que devuelve el backend o sumamos 1 al actual
          int current = _apoyosOverride ?? 0; // fallback
          _apoyosOverride = response['currentApoyos'] ?? (current + 1);
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleUnjoinReport(int reporteId) async {
    final confirm = await _confirmAction('¿Retirar apoyo?', 'Dejarás de apoyar este reporte.', 'Retirar', Colors.redAccent);
    if (!confirm) return;

    setState(() => _isProcessing = true);
    try {
      final response = await _reporteService.quitarApoyoPendiente(reporteId);
      if (!mounted) return;

      final success = response['statusCode'] == 200;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response['message'] ?? 'Acción realizada'),
        backgroundColor: success ? Colors.orange : Colors.red,
      ));

      if (success) {
        setState(() {
          // Actualización Local Inmediata
          _isJoinedOverride = false;
          int current = _apoyosOverride ?? 1; // fallback
          // Usamos el conteo que devuelve el backend o restamos 1
          int newVal = response['currentApoyos'] ?? (current - 1);
          _apoyosOverride = newVal < 0 ? 0 : newVal;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.read<AuthNotifier>();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _returnWithData(); // Ejecutar nuestra lógica de retorno personalizada
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de Reporte Pendiente'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _returnWithData, // Botón flecha
          ),
        ),
        body: FutureBuilder<ReporteDetallado>(
          future: _reporteFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const EsqueletoReporteDetalle();
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(child: Text('Error: ${snapshot.error ?? "No encontrado"}'));
            }

            final reporte = snapshot.data!;
            final bool esMiReporte = reporte.idAutor == authNotifier.userId;

            // --- Lógica Híbrida de Estado ---
            // 1. Si tenemos un override local (porque el usuario tocó botones), USAMOS ESE.
            // 2. Si _isJoinedOverride es null (primera carga), usamos lo que dice la API.
            final bool estaUnido = _isJoinedOverride ?? reporte.usuarioActualUnido ?? false;
            
            // Misma lógica para el conteo:
            // Si es null, inicializamos _apoyosOverride con lo que vino de la API para futuras referencias
            if (_apoyosOverride == null) {
               _apoyosOverride = reporte.apoyosPendientes;
            }
            final int conteoAMostrar = _apoyosOverride ?? reporte.apoyosPendientes;

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      ReporteHeader(reporte: reporte),
                      const Divider(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ubicación del Reporte', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 8),
                            MapaVerificacion(initialCenter: reporte.location),
                          ],
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),

                if (!esMiReporte)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        child: estaUnido
                            ? ElevatedButton.icon( // Botón VERDE (Unido)
                                icon: _isProcessing
                                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Icon(Icons.check_circle, size: 20),
                                label: Text('Unido (+${conteoAMostrar})'),
                                onPressed: _isProcessing ? null : () => _handleUnjoinReport(reporte.id),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade700,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              )
                            : ElevatedButton.icon( // Botón AZUL (Unirme)
                                icon: _isProcessing
                                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Icon(Icons.add, size: 20),
                                label: const Text('¡Yo también! Unirme'),
                                onPressed: _isProcessing ? null : () => _handleJoinReport(reporte.id),
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SafeArea(
                        child: Text(
                      "Este es tu reporte (${conteoAMostrar} apoyos)",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                    )),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}