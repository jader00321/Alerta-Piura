import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_resumen_model.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_lista_actividad.dart';
import 'package:mobile_app/widgets/mi_actividad/tarjeta_actividad.dart';

enum Fetcher { misReportes, misApoyos, misComentarios, misSeguimientos }

class ActivityListView extends StatelessWidget {
  final Fetcher fetcher;
  final List<ReporteResumen> reportes;
  final bool isLoading;
  final Future<void> Function() onRefresh;
  final Function(int) onCancelarReporte;
  final Function(int) onNavigateToDetail;

  const ActivityListView({
    super.key,
    required this.fetcher,
    required this.reportes,
    required this.isLoading,
    required this.onRefresh,
    required this.onCancelarReporte,
    required this.onNavigateToDetail,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && reportes.isEmpty) {
      return const EsqueletoListaActividad();
    }

    if (reportes.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'No hay actividad para mostrar en esta sección.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8.0),
        itemCount: reportes.length,
        itemBuilder: (context, index) {
          final reporte = reportes[index];

          Widget? trailingAction;
          if (fetcher == Fetcher.misReportes &&
              reporte.estado == 'pendiente_verificacion') {
            trailingAction = TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              child: const Text('Cancelar',
                  style: TextStyle(color: Colors.red, fontSize: 12)),
              onPressed: () => onCancelarReporte(reporte.id),
            );
          }

          return TarjetaActividad(
            reporte: reporte,
            fetcher: fetcher,
            onTap: () => onNavigateToDetail(reporte.id),
            trailingAction: trailingAction,
          );
        },
      ),
    );
  }
}
