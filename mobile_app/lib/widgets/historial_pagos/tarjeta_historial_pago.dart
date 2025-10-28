import 'package:flutter/material.dart';
import 'package:mobile_app/models/historial_pago_model.dart';

/// {@template tarjeta_historial_pago}
/// Widget de tarjeta que muestra un resumen de una transacción de pago
/// en la lista de [PantallaHistorialPagos].
///
/// Muestra el estado de la transacción (Aprobado/Fallido) con un icono,
/// el nombre del plan, la fecha y el monto pagado.
/// Es tappable ([onTap]) para navegar a la [PantallaDetalleBoleta].
/// {@endtemplate}
class TarjetaHistorialPago extends StatelessWidget {
  /// Los datos del historial de pago a mostrar.
  final HistorialPago pago;
  /// Callback que se ejecuta al tocar la tarjeta.
  final VoidCallback onTap;

  /// {@macro tarjeta_historial_pago}
  const TarjetaHistorialPago({
    super.key,
    required this.pago,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    /// Determina el estado para la UI (actualmente solo 'APROBADO' es éxito).
    final bool isApproved = pago.estadoTransaccion == 'APROBADO';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: ListTile(
        /// Icono de estado (Éxito o Error).
        leading: CircleAvatar(
          backgroundColor:
              isApproved ? Colors.green.shade100 : Colors.red.shade100,
          child: Icon(
            isApproved ? Icons.check_circle_outline : Icons.error_outline,
            color: isApproved ? Colors.green.shade800 : Colors.red.shade800,
          ),
        ),
        /// Nombre del plan.
        title: Text(
          'Suscripción: ${pago.nombrePlan}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        /// Fecha de pago.
        subtitle: Text('Pagado el: ${pago.fechaFormateada}'),
        /// Monto y estado.
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
            Text(
              pago.estadoTransaccion,
              style: TextStyle(
                fontSize: 12,
                color: isApproved ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ],
        ),
        onTap: onTap, // Permite navegar al detalle de la boleta.
      ),
    );
  }
}