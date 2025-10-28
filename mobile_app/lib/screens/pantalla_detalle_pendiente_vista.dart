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
/// Pantalla que muestra una vista detallada pero *simplificada* de un reporte
/// que aún está pendiente de verificación.
///
/// Está orientada a usuarios que ven un reporte pendiente en la lista
/// "Cerca de Ti" y quieren más contexto antes de decidir si "unirse".
/// Muestra [ReporteHeader], [MapaVerificacion] y un botón "Unirme".
/// {@endtemplate}
class PantallaDetallePendienteVista extends StatefulWidget {
  /// El ID del reporte pendiente a mostrar.
  final int reporteId;

  /// {@macro pantalla_detalle_pendiente_vista}
  const PantallaDetallePendienteVista({super.key, required this.reporteId});

  @override
  State<PantallaDetallePendienteVista> createState() =>
      _PantallaDetallePendienteVistaState();
}

/// Estado para [PantallaDetallePendienteVista].
///
/// Maneja la carga de los detalles del reporte pendiente y la acción de "unirse".
class _PantallaDetallePendienteVistaState
    extends State<PantallaDetallePendienteVista> {
  final ReporteService _reporteService = ReporteService();
  
  /// Futuro que contiene los detalles completos del reporte.
  late Future<ReporteDetallado> _reporteFuture;
  /// Indica si se está procesando la acción de unirse.
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _reporteFuture = _reporteService.getReporteById(widget.reporteId);
  }

  /// Maneja la acción de unirse al reporte pendiente.
  ///
  /// Llama a [ReporteService.unirseReportePendiente] y, si tiene éxito,
  /// cierra la pantalla devolviendo `true` para indicar a la pantalla anterior
  /// (`PantallaCercaDeTi`) que debe refrescar su lista.
  Future<void> _handleJoinReport(int reporteId) async {
    if (_isJoining) {
      return;
    }

    setState(() => _isJoining = true);

    Map<String, dynamic> response = {};
    try {
      response = await _reporteService.unirseReportePendiente(reporteId);
    } catch (e) {
      response = {
        'statusCode': 500,
        'message': 'Error inesperado al intentar unirse.'
      };
      debugPrint("Error en _handleJoinReport (Detalle Pendiente): $e");
    }

    if (!mounted) return;

    final message = response['message'] ?? 'Ocurrió un error.';
    final success = response['statusCode'] == 201 ||
        (response['statusCode'] == 200 &&
            message.contains('Ya te has unido')); // Ajuste para posible mensaje de éxito existente

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: success
          ? Colors.green
          : (response['statusCode'] == 403 ? Colors.orange : Colors.red),
    ));

    if (success) {
      Navigator.pop(context, true); // Devuelve true al éxito
    } else {
      setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.read<AuthNotifier>();

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Reporte Pendiente')),
      body: FutureBuilder<ReporteDetallado>(
        future: _reporteFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const EsqueletoReporteDetalle();
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
                child: Text(
                    'Error al cargar el reporte: ${snapshot.error ?? "No encontrado"}'));
          }

          final reporte = snapshot.data!;
          // El usuario puede unirse si el reporte está pendiente Y no es el autor.
          final bool puedeUnirse = reporte.estado == 'pendiente_verificacion' &&
              reporte.idAutor != authNotifier.userId;

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
                          Text('Ubicación del Reporte',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          MapaVerificacion(initialCenter: reporte.location),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80), // Espacio para el botón
                  ],
                ),
              ),
              if (puedeUnirse)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _isJoining
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.add, size: 20),
                        label: const Text('¡Yo también! Unirme'),
                        onPressed: _isJoining ? null : () => _handleJoinReport(reporte.id),
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}