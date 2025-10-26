import 'package:flutter/material.dart';
import 'package:mobile_app/models/historial_pago_model.dart';

class TarjetaHistorialPago extends StatelessWidget {
  final HistorialPago pago;
  final VoidCallback onTap;

  const TarjetaHistorialPago({
    super.key,
    required this.pago,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isApproved = pago.estadoTransaccion == 'APROBADO';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isApproved ? Colors.green.shade100 : Colors.red.shade100,
          child: Icon(
            isApproved ? Icons.check_circle_outline : Icons.error_outline,
            color: isApproved ? Colors.green.shade800 : Colors.red.shade800,
          ),
        ),
        title: Text(
          'Suscripción: ${pago.nombrePlan}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Pagado el: ${pago.fechaFormateada}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'S/ ${pago.montoPagado}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: theme.colorScheme.primary,
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
