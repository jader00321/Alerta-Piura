// lib/screens/reporte_detalle_screen.dart
import 'package:flutter/material.dart';
//import 'package:mobile_app/api/lider_service.dart'; // Necesario para reportar usuario
import 'package:mobile_app/api/reporte_service.dart';
import 'package:mobile_app/api/seguimiento_service.dart';
import 'package:mobile_app/models/reporte_detallado_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
// Importar los widgets de layout
import 'package:mobile_app/widgets/reporte_detalle/layout_detalle_reporte.dart';
// Importar widgets existentes
import 'package:mobile_app/widgets/esqueletos/esqueleto_reporte_detalle.dart';
import 'package:mobile_app/api/perfil_service.dart';
import 'package:mobile_app/screens/pantalla_editar_reporte_autor.dart';

class ReporteDetalleScreen extends StatefulWidget {
  final int reporteId;
  const ReporteDetalleScreen({super.key, required this.reporteId});

  @override
  State<ReporteDetalleScreen> createState() => _ReporteDetalleScreenState();
}

class _ReporteDetalleScreenState extends State<ReporteDetalleScreen> {
  // --- SERVICIOS ---
  final ReporteService _reporteService = ReporteService();
  final PerfilService _perfilService = PerfilService();
  final SeguimientoService _seguimientoService = SeguimientoService();

  // --- ESTADO ---
  late Future<ReporteDetallado> _reporteFuture;
  final TextEditingController _comentarioController = TextEditingController();
  bool _isPostingComment = false;
  bool _isLoadingFollow = true;
  bool _isFollowing = false;
  bool _dataChanged = false; // Flag para notificar a la pantalla anterior

  // --- CICLO DE VIDA ---
  @override
  void initState() {
    super.initState();
    _loadReporteData();
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  void setStateIfMounted(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  // --- LÓGICA DE DATOS ---
  Future<void> _loadReporteData({bool keepFollowState = false}) async {
    final reporteLoader = _reporteService.getReporteById(widget.reporteId);
    if (mounted)
      setState(() {
        _reporteFuture = reporteLoader;
      });

    if (!keepFollowState) {
      await _verificarEstadoSeguimiento();
    }
    try {
      await reporteLoader;
    } catch (e) {
      print("Error en _loadReporteData al esperar reporte: $e");
    }
  }

  Future<void> _verificarEstadoSeguimiento() async {
    // ... (sin cambios) ...
    if (!mounted) return;
    final isAuthenticated = context.read<AuthNotifier>().isAuthenticated;
    if (!isAuthenticated) {
      setStateIfMounted(() => _isLoadingFollow = false);
      return;
    }
    setStateIfMounted(() => _isLoadingFollow = true);
    try {
      final following =
          await _seguimientoService.verificarSeguimiento(widget.reporteId);
      if (mounted) {
        setStateIfMounted(() {
          _isFollowing = following;
          _isLoadingFollow = false;
        });
      }
    } catch (e) {
      if (mounted) setStateIfMounted(() => _isLoadingFollow = false);
      print("Error verificando seguimiento: $e");
    }
  }

  // --- HANDLERS (CALLBACKS) ---
  Future<void> _toggleFollow() async {
    // ... (sin cambios) ...
    if (!mounted || _isLoadingFollow) return;
    final isAuthenticated = context.read<AuthNotifier>().isAuthenticated;
    if (!isAuthenticated) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    setStateIfMounted(() => _isLoadingFollow = true);
    String message = 'Error al procesar la solicitud.';
    bool success = false;
    try {
      if (_isFollowing) {
        success =
            await _seguimientoService.dejarDeSeguirReporte(widget.reporteId);
        if (success) message = 'Has dejado de seguir este reporte.';
      } else {
        success = await _seguimientoService.seguirReporte(widget.reporteId);
        if (success) message = 'Ahora sigues este reporte.';
      }

      if (success && mounted) {
        _dataChanged = true;
        setStateIfMounted(() {
          _isFollowing = !_isFollowing;
          _isLoadingFollow = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.green));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red));
        setStateIfMounted(() => _isLoadingFollow = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error de conexión.'), backgroundColor: Colors.red));
        setStateIfMounted(() => _isLoadingFollow = false);
      }
    }
  }

  Future<void> _onSupportReport() async {
    // ... (sin cambios) ...
    final response = await _reporteService.apoyarReporte(widget.reporteId);
    if (mounted) {
      final message = response['message'] ?? 'Acción procesada.';
      final success =
          response['statusCode'] == 200 || response['statusCode'] == 201;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
      if (success) {
        _dataChanged = true;
        _loadReporteData(keepFollowState: true); // Recargar datos
      }
    }
  }

  Future<void> _onSupportComment(int commentId) async {
    // ... (sin cambios) ...
    final response = await _reporteService.apoyarComentario(commentId);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response['message'])));
      _loadReporteData(keepFollowState: true); // Recargar datos
    }
  }

  Future<void> _postComentario() async {
    // ... (sin cambios) ...
    if (_comentarioController.text.trim().isEmpty || _isPostingComment) return;
    setStateIfMounted(() => _isPostingComment = true);

    final success = await _reporteService.createComentario(
        widget.reporteId, _comentarioController.text.trim());

    if (mounted) {
      if (success) {
        _comentarioController.clear();
        _dataChanged = true;
        _loadReporteData(keepFollowState: true); // Recargar datos
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error al enviar comentario.'),
              backgroundColor: Colors.red),
        );
      }
      setStateIfMounted(() => _isPostingComment = false);
    }
  }

  void _showEditCommentDialog(int commentId, String currentText) {
    // ... (sin cambios) ...
    final textController = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Comentario'),
        content: TextField(
            controller: textController,
            autocorrect: false,
            decoration: const InputDecoration(hintText: 'Nuevo comentario...')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (textController.text.isNotEmpty) {
                Navigator.pop(ctx);
                await _reporteService.editarComentario(
                    commentId, textController.text);
                _loadReporteData(keepFollowState: true);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showConfirmDeleteDialog(int commentId) {
    // ... (sin cambios) ...
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Comentario'),
        content: const Text('¿Estás seguro? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await _reporteService.eliminarComentario(commentId);
              _loadReporteData(keepFollowState: true);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showReportCommentDialog(int commentId) {
    // ... (sin cambios) ...
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reportar Comentario'),
        content: TextField(
            controller: textController,
            decoration:
                const InputDecoration(hintText: 'Motivo del reporte...')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (textController.text.isNotEmpty) {
                Navigator.pop(ctx);
                await _reporteService.reportarComentario(
                    commentId, textController.text);
                if (mounted)
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Gracias, tu reporte ha sido enviado.')));
              }
            },
            child: const Text('Reportar'),
          ),
        ],
      ),
    );
  }

  void _showReportUserDialog(int userId, String userAlias) {
    // Obtener el ID del usuario actual
    final authNotifier = context.read<AuthNotifier>();
    final currentUserId = authNotifier.userId;

    // Validar que no se reporte a sí mismo
    if (currentUserId == userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No puedes reportarte a ti mismo.'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reportar a $userAlias'),
        content: TextField(
            controller: textController,
            decoration:
                const InputDecoration(hintText: 'Motivo del reporte...')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              final motivo = textController.text.trim();
              if (motivo.isNotEmpty) {
                Navigator.pop(ctx); // Cerrar dialogo ANTES de la llamada async
                try {
                  // *** LLAMAR AL SERVICIO CORRECTO ***
                  final response = await _perfilService.reportarUsuario(
                      userId, motivo); // Usa PerfilService
                  // *** FIN LLAMADA ***

                  if (mounted) {
                    final message = response['message'] ?? 'Error desconocido';
                    final success = response['statusCode'] == 201;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(message),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ));
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Error al reportar usuario: $e'),
                        backgroundColor: Colors.red));
                  }
                }
              }
            },
            child: const Text('Reportar Usuario'),
          ),
        ],
      ),
    );
  }

  // --- NUEVOS HANDLERS PARA BOTONES DE AUTOR ---
  Future<void> _handleEditReportAuthor(ReporteDetallado reporte) async {
    // Navega a la nueva pantalla de edición
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PantallaEditarReporteAutor(reporteInicial: reporte)),
    );
    // Si la pantalla de edición devolvió true (cambios guardados), recarga los datos
    if (result == true && mounted) {
      _loadReporteData(keepFollowState: true); // Mantiene estado de 'Seguir'
    }
  }

  void _handleChatAuthor(ReporteDetallado reporte) {
    // Reutilizar la navegación existente al chat
    Navigator.pushNamed(context, '/chat', arguments: {
      'reporteId': reporte.id,
      'reporteTitulo': reporte.titulo,
    });
  }
  // --- FIN NUEVOS HANDLERS ---

  // --- BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _dataChanged); // Notifica si hubo cambios
        return false; // Previene el pop automático
      },
      child: FutureBuilder<ReporteDetallado>(
        future: _reporteFuture,
        builder: (context, snapshot) {
          Widget body;
          ReporteDetallado? reporte; // Hacerlo nullable

          // Manejo de estados de carga y error
          if (snapshot.connectionState == ConnectionState.waiting &&
              !_dataChanged) {
            body = const EsqueletoReporteDetalle();
          } else if (snapshot.hasError) {
            body = Center(
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child:
                        Text('Error al cargar el reporte: ${snapshot.error}')));
          } else if (!snapshot.hasData) {
            body = const Center(child: Text('Reporte no encontrado.'));
          } else {
            // Tenemos datos
            reporte = snapshot.data!;
            body = LayoutDetalleReporte(
              reporte: reporte,
              authNotifier: authNotifier,
              onRefresh: () => _loadReporteData(keepFollowState: true),
              onSupportReport: _onSupportReport,
              onSupportComment: _onSupportComment,
              onPostComment: _postComentario,
              onEditComment: _showEditCommentDialog,
              onDeleteComment: _showConfirmDeleteDialog,
              onReportComment: _showReportCommentDialog,
              onReportUser: _showReportUserDialog,
              comentarioController: _comentarioController,
              isPostingComment: _isPostingComment,
            );
          }

          // Construcción del Scaffold principal
          return Scaffold(
            appBar: AppBar(
              title: const Text('Detalles del Reporte'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context, _dataChanged),
              ),
              // --- ACTIONS MODIFICADOS ---
              actions: [
                // Botón Seguir (solo si hay datos, está verificado y user logueado)
                if (reporte != null &&
                    reporte.estado == 'verificado' &&
                    authNotifier.isAuthenticated)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _isLoadingFollow
                        ? const Center(
                            child: Padding(
                                padding: EdgeInsets.all(14.0),
                                child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))))
                        : TextButton.icon(
                            onPressed: _toggleFollow,
                            icon: Icon(_isFollowing
                                ? Icons.bookmark_added
                                : Icons.bookmark_add_outlined),
                            label: Text(_isFollowing ? 'Siguiendo' : 'Seguir'),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.white),
                          ),
                  ),

                // NUEVO: Botones para Autor si está Pendiente y hay datos
                if (reporte != null &&
                    reporte.estado == 'pendiente_verificacion' &&
                    authNotifier.userId == reporte.idAutor) ...[
                  IconButton(
                    icon: const Icon(Icons.edit_note_outlined),
                    onPressed: () => _handleEditReportAuthor(
                        reporte!), // Llamar al nuevo handler
                    tooltip: 'Editar Mi Reporte',
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline),
                    onPressed: () =>
                        _handleChatAuthor(reporte!), // Llamar al nuevo handler
                    tooltip: 'Abrir Chat',
                  ),
                ],
              ],
              // --- FIN ACTIONS MODIFICADOS ---
            ),
            body: body, // El body es el FutureBuilder o estado correspondiente
          );
        },
      ),
    );
  }
}
