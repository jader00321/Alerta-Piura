// lib/widgets/mi_actividad/solicitudes_revision_view.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/models/solicitud_revision_model.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_lista_actividad.dart';

class SolicitudesRevisionView extends StatelessWidget {
  final List<SolicitudRevision> solicitudes;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  const SolicitudesRevisionView({
    super.key,
    required this.solicitudes,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && solicitudes.isEmpty) {
      return const EsqueletoListaActividad();
    }

    if (solicitudes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No has enviado solicitudes de revisión.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: solicitudes.length,
        itemBuilder: (context, index) {
          final solicitud = solicitudes[index];
          return Card(
            child: ListTile(
              title: Text(solicitud.titulo),
              subtitle: Text('Solicitado el: ${solicitud.fecha}'),
              trailing: Chip(
                label: Text(solicitud.estado,
                    style: const TextStyle(fontSize: 12)),
                backgroundColor: solicitud.estado == 'pendiente'
                    ? Colors.orange.shade100
                    : (solicitud.estado == 'aprobada'
                        ? Colors.green.shade100
                        : Colors.grey.shade300),
                labelStyle: TextStyle(
                  color: solicitud.estado == 'pendiente'
                      ? Colors.orange.shade900
                      : (solicitud.estado == 'aprobada'
                          ? Colors.green.shade900
                          : Colors.grey.shade800),
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/reporte_detalle',
                    arguments: solicitud.id_reporte);
              },
            ),
          );
        },
      ),
    );
  }
}
