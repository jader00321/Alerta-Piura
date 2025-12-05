import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_model.dart';

/// {@template report_summary_sheet}
/// Panel modal inferior rediseñado que muestra un resumen visual atractivo
/// de un [Reporte] seleccionado en el mapa.
///
/// Muestra la imagen del reporte (si existe) a la izquierda y los detalles
/// clave a la derecha. Incluye un botón de acción claro para ver más.
/// {@endtemplate}
class ReportSummarySheet extends StatelessWidget {
  final Reporte reporte;

  const ReportSummarySheet({super.key, required this.reporte});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Detectamos si hay una URL de imagen válida (que no sea vacía)
    // Nota: Tu modelo 'Reporte' actual podría no tener 'fotoUrl'. 
    // Si no lo tiene, asegúrate de agregarlo al modelo básico o usa un placeholder.
    // Asumiremos que podría tenerlo o usamos un placeholder visual.
    // Para este ejemplo, usaremos un icono grande si no hay foto.
    
    // *IMPORTANTE*: Si tu modelo `Reporte` (el básico del mapa) no tiene `fotoUrl`,
    // necesitarás agregarlo al modelo y a la query del backend `getAllReports`.
    // Aquí asumo que podrías agregarlo o usaré un placeholder por diseño.
    final String? fotoUrl = null; // TODO: Conectar con reporte.fotoUrl si se agrega al modelo

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- Drag Handle (Barrita gris) ---
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // --- Contenido Principal (Fila) ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Imagen o Icono (Izquierda)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 100,
                  height: 100,
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  child: fotoUrl != null
                      ? Image.network(
                          fotoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(Icons.broken_image, color: theme.colorScheme.primary),
                        )
                      : Icon(
                          _getCategoryIcon(reporte.categoria),
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                ),
              ),
              const SizedBox(width: 16),

              // 2. Información (Derecha)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chip de Categoría
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        reporte.categoria.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Título
                    Text(
                      reporte.titulo,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Descripción corta
                    if (reporte.descripcion != null)
                      Text(
                        reporte.descripcion!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // --- Botón de Acción ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/reporte_detalle', arguments: reporte.id);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: const Text("Ver Detalles Completos"),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String categoria) {
    // Puedes expandir esto según tus categorías reales
    final cat = categoria.toLowerCase();
    if (cat.contains('robo') || cat.contains('seguridad')) return Icons.security;
    if (cat.contains('basura') || cat.contains('limpieza')) return Icons.delete_outline;
    if (cat.contains('alumbrado') || cat.contains('luz')) return Icons.lightbulb_outline;
    if (cat.contains('pista') || cat.contains('bache')) return Icons.edit_road;
    return Icons.report_problem_outlined;
  }
}