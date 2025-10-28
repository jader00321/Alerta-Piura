import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_resumen_model.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_lista_actividad.dart';
import 'package:mobile_app/widgets/mi_actividad/tarjeta_actividad.dart';

/// Enum para identificar el contexto (pestaña) desde el cual se utiliza [ActivityListView].
/// Determina qué tipo de datos se esperan y cómo se renderizará [TarjetaActividad].
enum Fetcher {
  /// Para la pestaña "Mis Reportes".
  misReportes,
  /// Para la pestaña "Mis Apoyos".
  misApoyos,
  /// Para la pestaña "Mis Comentarios".
  misComentarios,
  /// Para la pestaña "Seguimientos".
  misSeguimientos
}

/// {@template activity_list_view}
/// Widget reutilizable **sin estado** que muestra una lista de reportes
/// resumidos ([ReporteResumen]) para las diferentes pestañas de la pantalla
/// [MiActividadScreen].
///
/// Recibe la lista de reportes ya cargada, el estado de carga y los callbacks
/// necesarios desde su widget padre ([MiActividadScreen]), que es el
/// encargado de gestionar el estado y la lógica de carga de datos.
/// Utiliza [TarjetaActividad] para renderizar cada elemento, pasándole el [fetcher]
/// para adaptar la UI.
/// Maneja los estados de carga inicial, lista vacía y permite refrescar
/// mediante `RefreshIndicator`.
/// {@endtemplate}
class ActivityListView extends StatelessWidget {
  /// Identifica la pestaña actual para la cual se muestra la lista
  /// (ej. Mis Reportes, Mis Apoyos).
  final Fetcher fetcher;
  /// La lista de [ReporteResumen] a mostrar.
  final List<ReporteResumen> reportes;
  /// Indica si el widget padre ([MiActividadScreen]) está actualmente cargando datos.
  final bool isLoading;
  /// Callback ejecutado cuando el usuario hace "pull-to-refresh".
  final Future<void> Function() onRefresh;
  /// Callback ejecutado cuando se presiona el botón "Cancelar" en un reporte
  /// (solo aplicable si `fetcher == Fetcher.misReportes`). Recibe el ID del reporte.
  final Function(int) onCancelarReporte;
  /// Callback ejecutado al tocar una tarjeta de reporte. Recibe el ID del reporte.
  final Function(int) onNavigateToDetail;

  /// {@macro activity_list_view}
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
    // Muestra el esqueleto solo durante la carga inicial si la lista está vacía.
    if (isLoading && reportes.isEmpty) {
      return const EsqueletoListaActividad();
    }

    // Muestra un mensaje si la lista está vacía después de cargar.
    if (reportes.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        // LayoutBuilder y ConstrainedBox aseguran que el mensaje de "vacío"
        // ocupe toda la pantalla y permita el "pull-to-refresh".
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

    // Muestra la lista de reportes si hay datos.
    return RefreshIndicator(
      onRefresh: onRefresh, // Habilita pull-to-refresh.
      child: ListView.builder(
        // Asegura que el RefreshIndicator funcione incluso si la lista es corta.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8.0),
        itemCount: reportes.length,
        itemBuilder: (context, index) {
          final reporte = reportes[index];

          // Construye el botón "Cancelar" solo si es aplicable.
          Widget? trailingAction;
          if (fetcher == Fetcher.misReportes &&
              reporte.estado == 'pendiente_verificacion') {
            trailingAction = TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact, // Botón más compacto.
              ),
              child: const Text('Cancelar',
                  style: TextStyle(color: Colors.red, fontSize: 12)),
              // Llama al callback del padre pasando el ID del reporte.
              onPressed: () => onCancelarReporte(reporte.id),
            );
          }

          // Usa la tarjeta unificada, pasando el contexto y la acción trailing.
          return TarjetaActividad(
            reporte: reporte,
            fetcher: fetcher, // Pasa el contexto de la pestaña.
            // Llama al callback del padre para la navegación.
            onTap: () => onNavigateToDetail(reporte.id),
            // Pasa el botón "Cancelar" (o null si no aplica).
            trailingAction: trailingAction,
          );
        },
      ),
    );
  }
}