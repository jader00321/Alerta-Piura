import 'package:flutter/material.dart';
import 'package:mobile_app/api/lider_service.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:mobile_app/models/reporte_detallado_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ReporteDetalleScreen extends StatefulWidget {
  final int reporteId;
  const ReporteDetalleScreen({super.key, required this.reporteId});

  @override
  State<ReporteDetalleScreen> createState() => _ReporteDetalleScreenState();
}

class _ReporteDetalleScreenState extends State<ReporteDetalleScreen> {
  final ReporteService _reporteService = ReporteService();
  final LiderService _liderService = LiderService();
  late Future<ReporteDetallado> _reporteFuture;
  final _comentarioController = TextEditingController();
  bool _isPostingComment = false;
  bool _dataChanged = false;

  @override
  void initState() {
    super.initState();
    _reporteFuture = _reporteService.getReporteById(widget.reporteId);
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  void _loadReporte() {
    setState(() {
      _reporteFuture = _reporteService.getReporteById(widget.reporteId);
      _dataChanged = true;
    });
  }

  Future<void> _postComentario() async {
    if (_comentarioController.text.trim().isEmpty) return;
    setState(() => _isPostingComment = true);
    final success = await _reporteService.createComentario(widget.reporteId, _comentarioController.text);
    if (success) {
      _comentarioController.clear();
      FocusScope.of(context).unfocus();
      _loadReporte();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al enviar comentario')));
      }
    }
    setState(() => _isPostingComment = false);
  }

  Future<void> _moderarReporte(bool aprobar) async {
    final success = aprobar
        ? await _liderService.aprobarReporte(widget.reporteId)
        : await _liderService.rechazarReporte(widget.reporteId);
    if (mounted && success) {
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al moderar el reporte')));
    }
  }

  void _showEditCommentDialog(int commentId, String currentText) {
    final textController = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Comentario'),
        content: TextField(controller: textController, autocorrect: false, decoration: const InputDecoration(hintText: 'Nuevo comentario...')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (textController.text.isNotEmpty) {
                await _reporteService.editarComentario(commentId, textController.text);
                _dataChanged = true;
                _loadReporte();
                Navigator.pop(ctx);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showConfirmDeleteDialog(int commentId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Comentario'),
        content: const Text('¿Estás seguro? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              await _reporteService.eliminarComentario(commentId);
              _dataChanged = true;
              _loadReporte();
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showReportCommentDialog(int commentId) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reportar Comentario'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: 'Motivo del reporte...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (textController.text.isNotEmpty) {
                await _reporteService.reportarComentario(commentId, textController.text);
                Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Gracias, tu reporte ha sido enviado.'),
                    behavior: SnackBarBehavior.floating
                  ));
                }
              }
            },
            child: const Text('Reportar'),
          ),
        ],
      ),
    );
  }

  void _showReportUserDialog(int userId, String userAlias) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reportar a $userAlias'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: 'Motivo del reporte...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              if (textController.text.isNotEmpty) {
                await _liderService.reportarUsuario(userId, textController.text);
                Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Gracias, el usuario ha sido reportado.'),
                    behavior: SnackBarBehavior.floating
                  ));
                }
              }
            },
            child: const Text('Reportar Usuario'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = Provider.of<AuthNotifier>(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.pop(context, _dataChanged);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Detalle del Reporte')),
        body: FutureBuilder<ReporteDetallado>(
          future: _reporteFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('Reporte no encontrado.'));
            }

            final reporte = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      // Image Section
                      if (reporte.fotoUrl != null)
                        Image.network(
                          reporte.fotoUrl!,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            return progress == null
                                ? child
                                : const SizedBox(height: 250, child: Center(child: CircularProgressIndicator()));
                          },
                        )
                      else
                        Container(
                          height: 200,
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50)),
                        ),

                      // Header Section
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Chip(
                              label: Text(reporte.categoria),
                              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                            ),
                            const SizedBox(height: 8),
                            Text(reporte.titulo, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Publicado por ${reporte.autor} • ${reporte.fechaCreacion}', style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 16),
                            if (reporte.descripcion != null && reporte.descripcion!.isNotEmpty) Text(reporte.descripcion!),
                          ],
                        ),
                      ),
                      
                      // Actions Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.thumb_up_alt_outlined),
                              label: Text('${reporte.apoyosCount} Apoyos'),
                              onPressed: () async {
                                if (!authNotifier.isAuthenticated) {
                                  Navigator.pushNamed(context, '/login');
                                  return;
                                }
                                final response = await _reporteService.apoyarReporte(reporte.id);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(response['message']),
                                    behavior: SnackBarBehavior.floating,
                                    margin: const EdgeInsets.all(16),
                                  ));
                                  _dataChanged = true;
                                  _loadReporte();
                                }
                              },
                            ),
                            const SizedBox(width: 16),
                            TextButton.icon(
                              icon: const Icon(Icons.comment_outlined),
                              label: Text('${reporte.comentarios.length} Comentarios'),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                      const Divider(thickness: 1, height: 1),

                      // Comments Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                        child: Text('Comentarios', style: Theme.of(context).textTheme.titleLarge),
                      ),
                      if (reporte.comentarios.isEmpty)
                        const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('No hay comentarios.')))
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: reporte.comentarios.length,
                          itemBuilder: (context, index) {
                            final c = reporte.comentarios[index];
                            final bool isOwner = c.autor == authNotifier.userAlias;
                            final bool isLider = authNotifier.userRole == 'lider_vecinal';

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(c.autor, style: const TextStyle(fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 4),
                                            Text(c.fechaCreacion, style: Theme.of(context).textTheme.bodySmall),
                                          ],
                                        ),
                                      ),
                                      if (authNotifier.isAuthenticated)
                                        SizedBox(
                                          width: 48,
                                          height: 48,
                                          child: PopupMenuButton<String>(
                                            tooltip: 'Más opciones',
                                            onSelected: (value) {
                                              if (value == 'editar') _showEditCommentDialog(c.id, c.comentario);
                                              if (value == 'eliminar') _showConfirmDeleteDialog(c.id);
                                              if (value == 'reportar_comentario') _showReportCommentDialog(c.id);
                                              if (value == 'reportar_usuario') _showReportUserDialog(c.idUsuario, c.autor);
                                            },
                                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                              if (isOwner) const PopupMenuItem<String>(value: 'editar', child: Text('Editar')),
                                              if (isOwner || isLider) const PopupMenuItem<String>(value: 'eliminar', child: Text('Eliminar')),
                                              if (!isOwner) const PopupMenuItem<String>(value: 'reportar_comentario', child: Text('Reportar Comentario')),
                                              if (isLider && !isOwner) const PopupMenuItem<String>(value: 'reportar_usuario', child: Text('Reportar Usuario')),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(c.comentario),
                                  Row(
                                    children: [
                                      TextButton.icon(
                                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                        icon: const Icon(Icons.thumb_up_alt_outlined, size: 16),
                                        label: Text(c.apoyosCount.toString()),
                                        onPressed: () async {
                                          if (!authNotifier.isAuthenticated) {
                                            Navigator.pushNamed(context, '/login');
                                            return;
                                          }
                                          final response = await _reporteService.apoyarComentario(c.id);
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text(response['message']),
                                              behavior: SnackBarBehavior.floating,
                                              margin: const EdgeInsets.all(16),
                                            ));
                                          }
                                          _dataChanged = true;
                                          _loadReporte();
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
                // --- CONDITIONAL COMMENT INPUT AREA ---
                if (authNotifier.isAuthenticated)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black.withOpacity(0.1))]
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _comentarioController,
                              decoration: const InputDecoration(hintText: 'Escribe un comentario...', border: InputBorder.none),
                              enabled: !_isPostingComment,
                            ),
                          ),
                          _isPostingComment
                              ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator()))
                              : IconButton(icon: const Icon(Icons.send), onPressed: _postComentario),
                        ],
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.login),
                      label: const Text('Inicia sesión para comentar o apoyar'),
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                    ),
                  ),
              ],
            );
          },
        ),
        bottomNavigationBar: FutureBuilder<ReporteDetallado>(
          future: _reporteFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final reporte = snapshot.data!;
            // The _userRole is loaded in initState, check against it
            if (authNotifier.userRole == 'lider_vecinal' && reporte.estado == 'pendiente_verificacion') {
              return BottomAppBar(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Aprobar'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        onPressed: () => _moderarReporte(true),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Rechazar'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        onPressed: () => _moderarReporte(false),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }
        ),
      ),
    );
  }
}