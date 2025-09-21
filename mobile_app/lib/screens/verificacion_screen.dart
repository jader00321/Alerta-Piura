import 'package:flutter/material.dart';
import 'package:mobile_app/api/lider_service.dart';
import 'package:mobile_app/models/reporte_moderacion_model.dart';
import 'package:mobile_app/models/reporte_pendiente_model.dart';

class VerificacionScreen extends StatelessWidget {
  const VerificacionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Now we have 3 tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Panel de Moderación'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.pending_actions), text: 'Pendientes'),
              Tab(icon: Icon(Icons.history), text: 'Historial'),
              Tab(icon: Icon(Icons.flag_outlined), text: 'Mis Reportes'), // New Tab
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab for pending reports
            _ReportesListView(
              fetcher: LiderService().getReportesPendientes,
              emptyMessage: 'No hay reportes pendientes.',
            ),
            // Tab for moderation history
            _ReportesListView(
              fetcher: LiderService().getReportesModerados,
              emptyMessage: 'No hay reportes en el historial.',
              isHistory: true,
            ),
            // View for the new tab
            const _MisReportesModeracionView(),
          ],
        ),
      ),
    );
  }
}

// Reusable widget for "Pendientes" and "Historial" lists
class _ReportesListView extends StatefulWidget {
  final Future<List<ReportePendiende>> Function() fetcher;
  final String emptyMessage;
  final bool isHistory;

  const _ReportesListView({
    required this.fetcher,
    required this.emptyMessage,
    this.isHistory = false,
  });

  @override
  State<_ReportesListView> createState() => _ReportesListViewState();
}

class _ReportesListViewState extends State<_ReportesListView> with AutomaticKeepAliveClientMixin {
  late Future<List<ReportePendiende>> _listFuture;

  @override
  void initState() {
    super.initState();
    _listFuture = widget.fetcher();
  }

  @override
  bool get wantKeepAlive => true;

  Icon _getStatusIcon(String status) {
    switch (status) {
      case 'verificado':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'rechazado':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.hourglass_empty, color: Colors.orange);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<List<ReportePendiende>>(
      future: _listFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar los datos.'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text(widget.emptyMessage));
        }

        final reportes = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _listFuture = widget.fetcher();
            });
          },
          child: ListView.builder(
            itemCount: reportes.length,
            itemBuilder: (context, index) {
              final reporte = reportes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: widget.isHistory ? _getStatusIcon(reporte.estado) : null,
                  title: Text(reporte.titulo),
                  subtitle: Text('${reporte.categoria} - ${reporte.fecha}'),
                  trailing: widget.isHistory
                      ? TextButton(
                          child: const Text('Solicitar Revisión'),
                          onPressed: () async {
                            final success = await LiderService().solicitarRevision(reporte.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(success ? 'Solicitud enviada al administrador. Ve a Mi Actividad para revisar tu solicitud' : 'Error al enviar la solicitud.'),
                                behavior: SnackBarBehavior.floating,
                              ));
                            }
                          },
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: () async {
                    final routeName = widget.isHistory ? '/reporte_detalle' : '/verificacion_detalle';
                    final result = await Navigator.pushNamed(context, routeName, arguments: reporte.id);
                    
                    if (result == true) {
                      setState(() {
                        _listFuture = widget.fetcher();
                      });
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// New widget for the "Mis Reportes" tab
class _MisReportesModeracionView extends StatefulWidget {
  const _MisReportesModeracionView();

  @override
  State<_MisReportesModeracionView> createState() => _MisReportesModeracionViewState();
}

class _MisReportesModeracionViewState extends State<_MisReportesModeracionView> with AutomaticKeepAliveClientMixin {
  final LiderService _liderService = LiderService();
  late Future<List<ReporteModeracion>> _listFuture;

  @override
  void initState() {
    super.initState();
    _listFuture = _fetchCombinedReports();
  }

  Future<List<ReporteModeracion>> _fetchCombinedReports() async {
    final commentReports = await _liderService.getMisComentariosReportados();
    final userReports = await _liderService.getMisUsuariosReportados();
    final combinedList = [...commentReports, ...userReports];
    combinedList.sort((a, b) => b.sortDate.compareTo(a.sortDate));
    return combinedList;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<List<ReporteModeracion>>(
      future: _listFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar tus reportes.'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No has realizado ningún reporte de moderación.'));
        }

        final reportes = snapshot.data!;
        return RefreshIndicator(
           onRefresh: () async {
            setState(() {
              _listFuture = _fetchCombinedReports();
            });
          },
          child: ListView.builder(
            itemCount: reportes.length,
            itemBuilder: (context, index) {
              final reporte = reportes[index];
              final isCommentReport = reporte.tipo == TipoReporteModeracion.comentario;
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: Icon(isCommentReport ? Icons.chat_bubble_outline : Icons.person_outline),
                  title: Text('Reporte de ${isCommentReport ? "Comentario" : "Usuario"}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('"${reporte.contenido}"\nMotivo: ${reporte.motivo}\nFecha: ${reporte.fecha}'),
                  trailing: Chip(
                    label: Text(reporte.estado),
                    backgroundColor: reporte.estado == 'pendiente' ? Colors.orange.shade100 : Colors.green.shade100,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}