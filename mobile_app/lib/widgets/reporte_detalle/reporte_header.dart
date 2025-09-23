import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_detallado_model.dart';

class ReporteHeader extends StatelessWidget {
  final ReporteDetallado reporte;
  const ReporteHeader({super.key, required this.reporte});

  Widget _buildInfoRow(BuildContext context, IconData icon, String title, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
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
                  TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.normal)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getUrgencyColor(String? urgency) {
    switch (urgency?.toLowerCase()) {
      case 'alta': return Colors.red;
      case 'media': return Colors.orange;
      case 'baja': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (reporte.fotoUrl != null)
          Image.network(
            reporte.fotoUrl!,
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : const SizedBox(height: 250, child: Center(child: CircularProgressIndicator())),
          )
        else
          Container(
            height: 200,
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50)),
          ),
        
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Chip(
                    label: Text(reporte.categoria),
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  if (reporte.urgencia != null)
                    Chip(
                      label: Text('Urgencia: ${reporte.urgencia}'),
                      backgroundColor: _getUrgencyColor(reporte.urgencia).withOpacity(0.2),
                      side: BorderSide(color: _getUrgencyColor(reporte.urgencia)),
                    )
                ],
              ),
              const SizedBox(height: 12),
              Text(reporte.titulo, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Publicado por ${reporte.autor} • ${reporte.fechaCreacion}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (reporte.codigoReporte != null) 
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text('Código de Seguimiento: ${reporte.codigoReporte}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.teal)),
                ),

              if (reporte.descripcion != null && reporte.descripcion!.isNotEmpty) ...[
                const Divider(height: 24),
                Text(reporte.descripcion!),
              ],

              const Divider(height: 24),
              _buildInfoRow(context, Icons.location_city_outlined, 'Distrito', reporte.distrito),
              _buildInfoRow(context, Icons.pin_drop_outlined, 'Referencia', reporte.referenciaUbicacion),
              _buildInfoRow(context, Icons.access_time, 'Hora del Incidente', reporte.horaIncidente),
              _buildInfoRow(context, Icons.groups_outlined, 'Impacto', reporte.impacto),

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