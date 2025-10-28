import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_detallado_model.dart';

/// {@template reporte_header}
/// Widget que muestra la cabecera principal con la información detallada de un reporte.
///
/// Incluye opcionalmente la imagen del reporte ([showImage]), chips de categoría y urgencia,
/// título, autor, fecha, descripción, código de seguimiento, y otros detalles
/// como distrito, referencia, hora, impacto y etiquetas.
/// Utiliza un helper [_buildInfoRow] para mostrar las líneas de detalles.
/// {@endtemplate}
class ReporteHeader extends StatelessWidget {
  /// Los datos detallados del reporte a mostrar.
  final ReporteDetallado reporte;
  /// Si es `true`, muestra la imagen principal del reporte en la parte superior.
  final bool showImage;

  /// {@macro reporte_header}
  const ReporteHeader({
    super.key,
    required this.reporte,
    this.showImage = true, // Por defecto, muestra la imagen.
  });

  /// Helper para construir una fila de información con icono, título y valor.
  /// Si el [value] es nulo o vacío, no renderiza nada.
  Widget _buildInfoRow(
      BuildContext context, IconData icon, String title, String? value) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink(); // No mostrar si no hay valor.
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: '$title: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                      text: value,
                      style: const TextStyle(fontWeight: FontWeight.normal)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Devuelve el color apropiado según el nivel de urgencia.
  Color _getUrgencyColor(String? urgency) {
    switch (urgency?.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Sección de la Imagen (condicional).
        if (showImage) ...[
          if (reporte.fotoUrl != null && reporte.fotoUrl!.isNotEmpty)
            Image.network(
              reporte.fotoUrl!,
              height: 250, // Altura estándar para la imagen.
              width: double.infinity,
              fit: BoxFit.cover,
              // Muestra un spinner mientras carga la imagen.
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : const SizedBox(
                      height: 250,
                      child: Center(child: CircularProgressIndicator())),
              // Muestra un icono de error si falla la carga.
              errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Center(
                      child: Icon(Icons.broken_image,
                          color: Colors.grey, size: 50))),
            )
          else
            // Muestra un placeholder si no hay imagen.
            Container(
              height: 200,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(
                  child: Icon(Icons.image_not_supported,
                      color: Colors.grey, size: 50)),
            ),
        ],
        /// Contenedor principal de la información textual.
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Chips de Categoría y Urgencia.
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Chip(
                    label: Text(reporte.categoria),
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  if (reporte.urgencia != null)
                    Chip(
                      label: Text('Urgencia: ${reporte.urgencia}'),
                      backgroundColor:
                          _getUrgencyColor(reporte.urgencia).withAlpha(51),
                      side: BorderSide(color: _getUrgencyColor(reporte.urgencia)),
                    )
                ],
              ),
              const SizedBox(height: 12),
              /// Título del Reporte.
              Text(reporte.titulo,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              /// Autor y Fecha de Creación.
              Text(
                'Publicado por ${reporte.autor} • ${reporte.fechaCreacion}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              /// Código de Seguimiento (si existe).
              if (reporte.codigoReporte != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                      'Código de Seguimiento: ${reporte.codigoReporte}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.teal)),
                ),

              /// Descripción (si existe).
              if (reporte.descripcion != null &&
                  reporte.descripcion!.isNotEmpty) ...[
                const Divider(height: 24),
                Text(reporte.descripcion!),
              ],

              const Divider(height: 24),

              /// Detalles adicionales usando el helper [_buildInfoRow].
              _buildInfoRow(
                  context, Icons.location_city_outlined, 'Distrito', reporte.distrito),
              _buildInfoRow(context, Icons.pin_drop_outlined, 'Referencia',
                  reporte.referenciaUbicacion),
              _buildInfoRow(context, Icons.access_time, 'Hora del Incidente',
                  reporte.horaIncidente),
              _buildInfoRow(
                  context, Icons.groups_outlined, 'Impacto', reporte.impacto),

              /// Sección de Etiquetas (si existen).
              if (reporte.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: reporte.tags.map((tag) => Chip(label: Text(tag))).toList(),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }
}