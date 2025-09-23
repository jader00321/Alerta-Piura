import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_detallado_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class CommentsSection extends StatelessWidget {
  final ReporteDetallado reporte;
  final Function(int, String) onEdit;
  final Function(int) onDelete;
  final Function(int) onReportComment;
  final Function(int, String) onReportUser;
  final Function(int) onSupportComment;

  const CommentsSection({
    super.key,
    required this.reporte,
    required this.onEdit,
    required this.onDelete,
    required this.onReportComment,
    required this.onReportUser,
    required this.onSupportComment,
  });

  @override
  Widget build(BuildContext context) {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'editar') onEdit(c.id, c.comentario);
                              if (value == 'eliminar') onDelete(c.id);
                              if (value == 'reportar_comentario') onReportComment(c.id);
                              if (value == 'reportar_usuario') onReportUser(c.idUsuario, c.autor);
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              if (isOwner) const PopupMenuItem<String>(value: 'editar', child: Text('Editar')),
                              if (isOwner || isLider) const PopupMenuItem<String>(value: 'eliminar', child: Text('Eliminar')),
                              if (!isOwner) const PopupMenuItem<String>(value: 'reportar_comentario', child: Text('Reportar Comentario')),
                              if (isLider && !isOwner) const PopupMenuItem<String>(value: 'reportar_usuario', child: Text('Reportar Usuario')),
                            ],
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
                          onPressed: () {
                            if (!authNotifier.isAuthenticated) {
                              Navigator.pushNamed(context, '/login');
                              return;
                            }
                            onSupportComment(c.id);
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
    );
  }
}