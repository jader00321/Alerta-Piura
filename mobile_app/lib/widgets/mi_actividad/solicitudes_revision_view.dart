import 'package:flutter/material.dart';
import 'package:mobile_app/models/solicitud_revision_model.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_lista_actividad.dart';

/// {@template solicitudes_revision_view}
/// Widget **sin estado** que muestra la lista de solicitudes de revisión
/// enviadas por el líder vecinal a los administradores.
///
/// Se utiliza como una de las pestañas en [MiActividadScreen] para líderes.
/// Recibe la lista de [SolicitudRevision] ya cargada desde el padre.
/// Maneja los estados de carga inicial y lista vacía, y permite refrescar.
/// Tocar un elemento navega al detalle del reporte asociado.
/// {@endtemplate}
class SolicitudesRevisionView extends StatelessWidget {
  /// La lista de [SolicitudRevision] a mostrar.
  final List<SolicitudRevision> solicitudes;
  /// Indica si el widget padre ([MiActividadScreen]) está cargando datos.
  final bool isLoading;
  /// Callback ejecutado cuando el usuario hace "pull-to-refresh".
  final Future<void> Function() onRefresh;

  /// {@macro solicitudes_revision_view}
  const SolicitudesRevisionView({
    super.key,
    required this.solicitudes,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Muestra esqueleto durante la carga inicial si la lista está vacía.
    if (isLoading && solicitudes.isEmpty) {
      return const EsqueletoListaActividad();
    }

    // Muestra mensaje si la lista está vacía después de cargar.
    if (solicitudes.isEmpty) {
      return RefreshIndicator( // Permite refrescar aunque esté vacío
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
                    'No has enviado solicitudes de revisión.',
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

    // Muestra la lista de solicitudes si hay datos.
    return RefreshIndicator(
      onRefresh: onRefresh, // Habilita pull-to-refresh.
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: solicitudes.length,
        itemBuilder: (context, index) {
          final solicitud = solicitudes[index];
          // Determina el color y el icono del chip de estado.
          MaterialColor statusColor;
          IconData statusIcon;
          switch (solicitud.estado) {
            case 'pendiente':
              statusColor = Colors.orange;
              statusIcon = Icons.hourglass_empty_outlined;
              break;
            case 'aprobada':
              statusColor = Colors.green;
              statusIcon = Icons.check_circle_outline;
              break;
            case 'desestimada':
              statusColor = Colors.grey;
              statusIcon = Icons.cancel_outlined;
              break;
            default:
              statusColor = Colors.grey;
              statusIcon = Icons.help_outline;
              break;
          }

          // Renderiza cada solicitud en un ListTile dentro de un Card.
          return Card(
            child: ListTile(
              title: Text(solicitud.titulo), // Título del reporte asociado.
              subtitle: Text('Solicitado el: ${solicitud.fecha}'),
              trailing: Chip(
                avatar: Icon(statusIcon, size: 14, color: statusColor.shade900),
                label: Text(solicitud.estado, style: const TextStyle(fontSize: 12)),
                backgroundColor: statusColor.shade100,
                labelStyle: TextStyle(
                  color: statusColor.shade900,
                ),
                visualDensity: VisualDensity.compact,
              ),
              onTap: () {
                // Navega al detalle del reporte asociado a la solicitud.
                Navigator.pushNamed(context, '/reporte_detalle',
                    arguments: solicitud.idReporte);
              },
            ),
          );
        },
      ),
    );
  }
}