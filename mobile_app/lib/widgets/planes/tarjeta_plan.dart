import 'package:flutter/material.dart';
import 'package:mobile_app/models/plan_suscripcion_model.dart';

class TarjetaPlan extends StatelessWidget {
  final PlanSuscripcion plan;
  final VoidCallback onSelected;
  final bool isRecommended;

  const TarjetaPlan({
    super.key,
    required this.plan,
    required this.onSelected,
    this.isRecommended = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // LÓGICA CORREGIDA: Usamos una expresión regular para dividir por \n o \\n
    final features = plan.descripcion
            ?.split(RegExp(r'\\n|\n'))
            .where((s) => s.trim().isNotEmpty)
            .toList() ??
        [];

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: isRecommended ? theme.colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRecommended)
              Chip(
                label: const Text('Recomendado'),
                backgroundColor: theme.colorScheme.primary,
                labelStyle: TextStyle(color: theme.colorScheme.onPrimary),
              ),
            if (isRecommended) const SizedBox(height: 8),
            Text(
              plan.nombrePublico,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'S/ ${plan.precioMensual} / mes',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 32),
            // CÓDIGO CORREGIDO PARA RENDERIZAR LA LISTA
            if (features.isEmpty)
              const Text('No hay beneficios detallados.')
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: features
                    .map((feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle_outline,
                                  color: Colors.green.shade600, size: 20),
                              const SizedBox(width: 12),
                              // Limpiamos guiones y espacios extra
                              Expanded(
                                  child: Text(
                                      feature.trim().replaceFirst('- ', ''))),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onSelected,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Seleccionar Plan'),
            ),
          ],
        ),
      ),
    );
  }
}
