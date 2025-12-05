import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_app/api/perfil_service.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:mobile_app/api/seguimiento_service.dart';
import 'package:mobile_app/models/reporte_detallado_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/widgets/reporte_detalle/layout_detalle_reporte.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_reporte_detalle.dart';
import 'package:mobile_app/screens/pantalla_editar_reporte_autor.dart';

/// {@template reporte_detalle_screen}
/// Pantalla que muestra los detalles completos de un reporte ciudadano.
///
/// Carga los datos usando [ReporteService.getReporteById].
/// Permite al usuario interactuar con el reporte:
/// - Dar/Quitar Apoyo ([_onSupportReport])
/// - Seguir/Dejar de seguir ([_toggleFollow])
/// - Añadir/Editar/Eliminar/Reportar comentarios ([CommentsSection] callbacks)
/// - Reportar al autor del comentario ([_showReportUserDialog])
/// - Editar el reporte si es el autor y está pendiente ([_handleEditReportAuthor])
/// - Abrir el chat si es el autor y está pendiente ([_handleChatAuthor])
///
/// Utiliza [LayoutDetalleReporte] para estructurar el contenido.
/// Maneja los diferentes estados del reporte (verificado, pendiente, fusionado, oculto).
/// {@endtemplate}
class ReporteDetalleScreen extends StatefulWidget {
  /// El ID del reporte a mostrar.
  final int reporteId;

  /// {@macro reporte_detalle_screen}
  const ReporteDetalleScreen({super.key, required this.reporteId});

  @override
  State<ReporteDetalleScreen> createState() => _ReporteDetalleScreenState();
}

/// Estado para [ReporteDetalleScreen].
///
/// Maneja la carga de datos del reporte, estado de seguimiento,
/// envío de comentarios y lógica de interacción.
class _ReporteDetalleScreenState extends State<ReporteDetalleScreen> {
  final ReporteService _reporteService = ReporteService();
  final PerfilService _perfilService = PerfilService();
  final SeguimientoService _seguimientoService = SeguimientoService();

  /// Futuro que contiene los detalles del reporte.
  late Future<ReporteDetallado> _reporteFuture;
  final TextEditingController _comentarioController = TextEditingController();
  /// Indica si se está enviando un comentario.
  bool _isPostingComment = false;
  /// Indica si se está cargando el estado de seguimiento.
  bool _isLoadingFollow = true;
  /// Indica si el usuario actual sigue este reporte.
  bool _isFollowing = false;
  /// Flag para indicar si algún dato cambió (apoyo, comentario, seguimiento)
  /// y se debe pasar como resultado al cerrar la pantalla.
  bool _dataChanged = false;

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

  /// Helper para llamar a setState solo si el widget está montado.
  void setStateIfMounted(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  /// Carga o recarga los datos detallados del reporte y, opcionalmente,
  /// el estado de seguimiento.
  ///
  /// [keepFollowState]: Si es `true`, no vuelve a verificar si el usuario sigue el reporte.
  Future<void> _loadReporteData({bool keepFollowState = false}) async {
    final reporteLoader = _reporteService.getReporteById(widget.reporteId);
    if (mounted) {
      // Asigna el futuro inmediatamente para que el FutureBuilder se actualice
      setState(() {
        _reporteFuture = reporteLoader;
      });
    }

    // Si no se pide mantener el estado, verifica si el usuario sigue el reporte
    if (!keepFollowState) {
      await _verificarEstadoSeguimiento();
    }
    // Espera a que el reporte termine de cargar (maneja errores silenciosamente aquí)
    try {
      await reporteLoader;
    } catch (e) {
      debugPrint("Error en _loadReporteData al esperar reporte: $e");
      // El error se mostrará en el FutureBuilder
    }
  }

  /// Verifica si el usuario autenticado está siguiendo el reporte actual.
  Future<void> _verificarEstadoSeguimiento() async {
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
      if (mounted) {
        setStateIfMounted(() => _isLoadingFollow = false);
      }
      debugPrint("Error verificando seguimiento: $e");
    }
  }

  /// Cambia el estado de seguimiento (seguir/dejar de seguir) del reporte.
  /// Muestra [SnackBar] con el resultado.
  Future<void> _toggleFollow() async {
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
        if (success) {
          message = 'Has dejado de seguir este reporte.';
        }
      } else {
        success = await _seguimientoService.seguirReporte(widget.reporteId);
        if (success) {
          message = 'Ahora sigues este reporte.';
        }
      }

      if (mounted) {
        if (success) {
          _dataChanged = true; // Marca que hubo un cambio
          setStateIfMounted(() {
            _isFollowing = !_isFollowing;
            _isLoadingFollow = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.green));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.red));
          setStateIfMounted(() => _isLoadingFollow = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error de conexión.'), backgroundColor: Colors.red));
        setStateIfMounted(() => _isLoadingFollow = false);
      }
    }
  }

  /// Envía una solicitud para dar/quitar apoyo al reporte.
  /// Recarga los datos del reporte si tiene éxito.
  Future<void> _onSupportReport() async {
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
        _dataChanged = true; // Marca que hubo un cambio
        _loadReporteData(keepFollowState: true); // Recarga manteniendo estado follow
      }
    }
  }

  /// Envía una solicitud para dar/quitar apoyo a un comentario específico.
  /// Recarga los datos del reporte.
  Future<void> _onSupportComment(int commentId) async {
    final response = await _reporteService.apoyarComentario(commentId);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response['message'])));
      _dataChanged = true; // Marca que hubo un cambio (podría ser redundante)
      _loadReporteData(keepFollowState: true); // Recarga manteniendo estado follow
    }
  }

  /// Envía el comentario ingresado a la API.
  /// Limpia el campo y recarga los datos si tiene éxito.
  Future<void> _postComentario() async {
    if (_comentarioController.text.trim().isEmpty || _isPostingComment) return;
    setStateIfMounted(() => _isPostingComment = true);

    final success = await _reporteService.createComentario(
        widget.reporteId, _comentarioController.text.trim());

    if (mounted) {
      if (success) {
        _comentarioController.clear();
        _dataChanged = true; // Marca que hubo un cambio
        _loadReporteData(keepFollowState: true); // Recarga manteniendo estado follow
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

  /// Muestra un diálogo para editar un comentario existente.
  void _showEditCommentDialog(int commentId, String currentText) {
    final textController = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Comentario'),
        content: TextField(
            controller: textController,
            autocorrect: false,
            decoration:
                const InputDecoration(hintText: 'Nuevo comentario...')),
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
                _dataChanged = true; // Marca que hubo un cambio
                _loadReporteData(keepFollowState: true); // Recarga
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  /// Muestra un diálogo de confirmación para eliminar un comentario.
  void _showConfirmDeleteDialog(int commentId) {
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
              _dataChanged = true; // Marca que hubo un cambio
              _loadReporteData(keepFollowState: true); // Recarga
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  /// Muestra un diálogo para reportar un comentario por contenido inapropiado.
  void _showReportCommentDialog(int commentId) {
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
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Gracias, tu reporte ha sido enviado.')));
                }
              }
            },
            child: const Text('Reportar'),
          ),
        ],
      ),
    );
  }

  /// Muestra un diálogo para reportar al autor de un comentario.
  void _showReportUserDialog(int userId, String userAlias) {
    final authNotifier = context.read<AuthNotifier>();
    final currentUserId = authNotifier.userId;

    // Evita que el usuario se reporte a sí mismo
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
                Navigator.pop(ctx);
                try {
                  final response =
                      await _perfilService.reportarUsuario(userId, motivo);

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

  /// Navega a [PantallaEditarReporteAutor] si las condiciones lo permiten.
  Future<void> _handleEditReportAuthor(ReporteDetallado reporte) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PantallaEditarReporteAutor(reporteInicial: reporte)),
    );
    // Si la edición fue exitosa, recarga los datos
    if (result == true && mounted) {
      _loadReporteData(keepFollowState: true);
    }
  }

  /// Navega a [ChatScreen] para el reporte actual.
  void _handleChatAuthor(ReporteDetallado reporte) {
    Navigator.pushNamed(context, '/chat', arguments: {
      'reporteId': reporte.id,
      'reporteTitulo': reporte.titulo,
      'fromReportDetails': true,
    });
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();

    // PopScope maneja el botón de retroceso para pasar el flag _dataChanged
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        Navigator.pop(context, _dataChanged);
      },
      child: FutureBuilder<ReporteDetallado>(
        future: _reporteFuture,
        builder: (context, snapshot) {
          Widget body;
          ReporteDetallado? reporte;

          // Muestra esqueleto solo en la carga inicial
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
            // Si hay datos, los usamos para construir el layout
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

          // Construye el Scaffold principal
          return Scaffold(
            appBar: AppBar(
              title: const Text('Detalles del Reporte'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context, _dataChanged),
              ),
              actions: [
                if (reporte != null && reporte.estado == 'verificado' && authNotifier.isAuthenticated)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _isLoadingFollow
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : TextButton.icon(
                            onPressed: _toggleFollow,
                            icon: Icon(_isFollowing ? Icons.bookmark_added : Icons.bookmark_add_outlined),
                            label: Text(_isFollowing ? 'Siguiendo' : 'Seguir'),
                            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
                          ),
                  ),
                
                // --- BOTONES DE EDICIÓN Y CHAT ---
                if (reporte != null && authNotifier.userId == reporte.idAutor) ...[
                  // Editar solo si es pendiente
                  if (reporte.estado == 'pendiente_verificacion')
                    IconButton(
                      icon: const Icon(Icons.edit_note_outlined),
                      onPressed: () => _handleEditReportAuthor(reporte!),
                      tooltip: 'Editar Mi Reporte',
                    ),
                  
                  // --- MODIFICACIÓN: CHAT SIEMPRE DISPONIBLE PARA EL AUTOR ---
                  // Se muestra en cualquier estado (pendiente, verificado, rechazado, fusionado)
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline),
                    onPressed: () => _handleChatAuthor(reporte!),
                    tooltip: 'Abrir Chat de Soporte',
                  ),
                ],
              ],
            ),
            body: body,
          );
        },
      ),
    );
  }
}