import 'package:flutter/material.dart';
import 'package:mobile_app/api/lider_service.dart';
import 'package:mobile_app/api/perfil_service.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:mobile_app/models/reporte_resumen_model.dart';
import 'package:mobile_app/models/solicitud_revision_model.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/auth_provider.dart';

class MiActividadScreen extends StatelessWidget {
  const MiActividadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the role directly from the provider. No need for Futures or loading states here.
    final userRole = Provider.of<AuthNotifier>(context, listen: false).userRole;
    final bool isLider = userRole == 'lider_vecinal';
    final int tabLength = isLider ? 4 : 3;

    return DefaultTabController(
      length: tabLength,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mi Actividad'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              const Tab(text: 'Mis Reportes'),
              const Tab(text: 'Mis Apoyos'),
              const Tab(text: 'Comentarios'),
              if (isLider) const Tab(text: 'Revisiones Solicitadas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const _ActivityListView(fetcher: Fetcher.misReportes),
            const _ActivityListView(fetcher: Fetcher.misApoyos),
            const _ActivityListView(fetcher: Fetcher.misComentarios),
            if (isLider) const _SolicitudesRevisionView(),
          ],
        ),
      ),
    );
  }
}

// Enum to differentiate which list to fetch
enum Fetcher { misReportes, misApoyos, misComentarios }

// Reusable widget for the first 3 tabs
class _ActivityListView extends StatefulWidget {
  final Fetcher fetcher;
  const _ActivityListView({required this.fetcher});

  @override
  State<_ActivityListView> createState() => _ActivityListViewState();
}

class _ActivityListViewState extends State<_ActivityListView> with AutomaticKeepAliveClientMixin {
  final PerfilService _perfilService = PerfilService();
  final ReporteService _reporteService = ReporteService();
  late Future<List<ReporteResumen>> _listFuture;

  @override
  void initState() {
    super.initState();
    _listFuture = _fetchData();
  }

  Future<List<ReporteResumen>> _fetchData() {
    switch (widget.fetcher) {
      case Fetcher.misReportes:
        return _perfilService.getMisReportes();
      case Fetcher.misApoyos:
        return _perfilService.getMisApoyos();
      case Fetcher.misComentarios:
        return _perfilService.getMisComentarios();
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<List<ReporteResumen>>(
      future: _listFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar los datos.'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay actividad para mostrar.'));
        }

        final reportes = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _listFuture = _fetchData();
            });
          },
          child: ListView.builder(
            itemCount: reportes.length,
            itemBuilder: (context, index) {
              final reporte = reportes[index];
              return ListTile(
                title: Text(reporte.titulo),
                subtitle: Text('Estado: ${reporte.estado} - ${reporte.fecha ?? 'N/A'}'),
                trailing: widget.fetcher == Fetcher.misReportes && reporte.estado == 'pendiente_verificacion'
                  ? TextButton(
                      child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Cancelar Reporte'),
                            content: const Text('¿Estás seguro de que quieres cancelar este reporte?'),
                            actions: [
                              TextButton(
                                child: const Text('No'),
                                onPressed: () => Navigator.pop(ctx),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                child: const Text('Sí, Cancelar'),
                                onPressed: () async {
                                  final success = await _reporteService.eliminarReporte(reporte.id);
                                  if (mounted) {
                                    Navigator.pop(ctx);
                                    if (success) {
                                      setState(() {
                                        _listFuture = _fetchData();
                                      });
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : const Icon(Icons.chevron_right),
                onTap: () async {
                  final result = await Navigator.pushNamed(
                    context, 
                    '/reporte_detalle', 
                    arguments: reporte.id
                  );
                  if (result == true) {
                    setState(() {
                      _listFuture = _fetchData();
                    });
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}

// Widget for the Leader's submitted review requests tab
class _SolicitudesRevisionView extends StatefulWidget {
  const _SolicitudesRevisionView();
  @override
  State<_SolicitudesRevisionView> createState() => __SolicitudesRevisionViewState();
}

class __SolicitudesRevisionViewState extends State<_SolicitudesRevisionView> with AutomaticKeepAliveClientMixin {
  late Future<List<SolicitudRevision>> _listFuture;

  @override
  void initState() {
    super.initState();
    _listFuture = LiderService().getMisSolicitudesRevision();
  }
  
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<List<SolicitudRevision>>(
      future: _listFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar las solicitudes.'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No has enviado solicitudes de revisión.'));
        }

        final solicitudes = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
               _listFuture = LiderService().getMisSolicitudesRevision();
            });
          },
          child: ListView.builder(
            itemCount: solicitudes.length,
            itemBuilder: (context, index) {
              final solicitud = solicitudes[index];
              return ListTile(
                title: Text(solicitud.titulo),
                subtitle: Text('Solicitado el: ${solicitud.fecha}'),
                trailing: Chip(
                  label: Text(solicitud.estado, style: const TextStyle(fontSize: 12)),
                  backgroundColor: solicitud.estado == 'pendiente' 
                      ? Colors.orange.shade100 
                      : (solicitud.estado == 'aprobada' ? Colors.green.shade100 : Colors.grey.shade300),
                ),
                onTap: () {
                  // Navigate to the public detail screen to see the report
                  Navigator.pushNamed(
                    context, 
                    '/reporte_detalle', 
                    arguments: solicitud.id_reporte // Use the report ID from the model
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}