import 'package:flutter/material.dart';
import 'package:mobile_app/models/plan_suscripcion_model.dart';

class ResumenPago extends StatelessWidget {
  final PlanSuscripcion plan;

  const ResumenPago({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumen de tu Compra', style: theme.textTheme.titleLarge),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(plan.nombrePublico, style: theme.textTheme.bodyLarge),
                Text('S/ ${plan.precioMensual}',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Suscripción mensual, renovable automáticamente.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey[600])),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total a Pagar:',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text('S/ ${plan.precioMensual}',
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
