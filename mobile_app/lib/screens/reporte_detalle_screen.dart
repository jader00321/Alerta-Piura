import 'package:flutter/material.dart';
import 'package:mobile_app/api/lider_service.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:mobile_app/models/reporte_detallado_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/widgets/reporte_detalle/reporte_header.dart';
import 'package:mobile_app/widgets/reporte_detalle/reporte_actions_bar.dart';
import 'package:mobile_app/widgets/reporte_detalle/comments_section.dart';

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

  // --- HANDLER FUNCTIONS ---
  Future<void> _onSupportReport() async {
    final response = await _reporteService.apoyarReporte(widget.reporteId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['message']),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16)));
      _loadReporte();
    }
  }

  Future<void> _onSupportComment(int commentId) async {
    final response = await _reporteService.apoyarComentario(commentId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['message']),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16)));
      _loadReporte();
    }
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
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    //final userRole = authNotifier.userRole;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Reporte'),
        // This ensures that when the user presses the back arrow,
        // we send back whether the data changed.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _dataChanged),
        ),
      ),
        body: FutureBuilder<ReporteDetallado>(
          future: _reporteFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error al cargar el reporte: ${snapshot.error}'));
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
                      ReporteHeader(reporte: reporte),
                      ReporteActionsBar(
                        apoyosCount: reporte.apoyosCount,
                        comentariosCount: reporte.comentarios.length,
                        onSupportPressed: _onSupportReport,
                      ),
                      const Divider(thickness: 1, height: 1),
                      CommentsSection(
                        reporte: reporte,
                        onEdit: _showEditCommentDialog,
                        onDelete: _showConfirmDeleteDialog,
                        onReportComment: _showReportCommentDialog,
                        onReportUser: _showReportUserDialog,
                        onSupportComment: _onSupportComment,
                      ),
                    ],
                  ),
                ),
                if (authNotifier.isAuthenticated)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(color: Theme.of(context).cardColor, boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black.withOpacity(0.1))]),
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
                              ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 24, height: 30, child: CircularProgressIndicator()))
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
                  const SizedBox(height: 16),
              ],
            );
          },
        ),
      );
  }
}
