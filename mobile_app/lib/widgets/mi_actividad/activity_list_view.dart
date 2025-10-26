// lib/widgets/mi_actividad/activity_list_view.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_resumen_model.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_lista_actividad.dart';
import 'package:mobile_app/widgets/mi_actividad/tarjeta_actividad.dart';

enum Fetcher { misReportes, misApoyos, misComentarios, misSeguimientos }

class ActivityListView extends StatelessWidget {
  final Fetcher fetcher;
  final List<ReporteResumen> reportes; // Recibe la lista de reportes ya cargada
  final bool isLoading; // Recibe el estado de carga del padre
  final Future<void> Function() onRefresh; // Callback para el RefreshIndicator
  final Function(int) onCancelarReporte; // Callback para el botón "Cancelar"
  final Function(int) onNavigateToDetail; // Callback para navegar

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

    // Muestra el mensaje de lista vacía
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

    // Muestra la lista de reportes
    return RefreshIndicator(
      onRefresh: onRefresh, // Llama a la función de refresco del padre
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
                visualDensity: VisualDensity.compact, // Más compacto
              ),
              child: const Text('Cancelar',
                  style: TextStyle(color: Colors.red, fontSize: 12)),
              onPressed: () =>
                  onCancelarReporte(reporte.id), // Llama al callback del padre
            );
          }
          return TarjetaActividad(
            reporte: reporte,
            fetcher: fetcher,
            onTap: () =>
                onNavigateToDetail(reporte.id), // Llama al callback del padre
            trailingAction: trailingAction, // Pasa el botón "Cancelar" (o null)
          );
        },
      ),
    );
  }
}
