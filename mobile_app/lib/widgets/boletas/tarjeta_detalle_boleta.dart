import 'package:flutter/material.dart';
import 'package:mobile_app/models/boleta_detalle_model.dart';

/// {@template tarjeta_detalle_boleta}
/// Widget que renderiza una vista detallada (tipo boleta o factura)
/// de una transacción de pago específica.
///
/// Utiliza el modelo [BoletaDetalle] para poblar los campos de forma
/// estructurada, incluyendo información del cliente, servicio y pago.
/// Se utiliza en [PantallaDetalleBoleta].
/// {@endtemplate}
class TarjetaDetalleBoleta extends StatelessWidget {
  /// Los datos detallados de la boleta a mostrar.
  final BoletaDetalle boleta;

  /// {@macro tarjeta_detalle_boleta}
  const TarjetaDetalleBoleta({super.key, required this.boleta});

  /// Helper local para construir una fila de detalle estandarizada.
  ///
  /// Muestra un [title] a la izquierda y un [value] a la derecha.
  /// [isBold] permite resaltar el valor (ej. para el total).
  Widget _buildDetailRow(BuildContext context, String title, String value,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[600])),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    /// Determina el estilo del chip de estado.
    final bool isApproved = boleta.estadoTransaccion == 'Aprobado';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Cabecera de la Boleta: Título y Estado.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Boleta de Venta',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  softWrap: true,
                ),
                const SizedBox(width: 4),
                Chip(
                  label: Text(boleta.estadoTransaccion),
                  backgroundColor:
                      isApproved ? Colors.green.shade100 : Colors.red.shade100,
                  labelStyle: TextStyle(
                      color: isApproved
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      fontWeight: FontWeight.bold),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            Text(
              'ID Transacción: ${boleta.idTransaccionPasarela}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const Divider(height: 30),

            /// Detalles del Cliente.
            Text('Facturado a:', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildDetailRow(context, 'Cliente', boleta.nombreUsuario),
            _buildDetailRow(context, 'Email', boleta.emailUsuario),

            const Divider(height: 30),

            /// Detalles del Producto/Servicio.
            Text('Descripción del Servicio:', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildDetailRow(context, 'Plan Contratado', boleta.nombrePlan),
            _buildDetailRow(
                context, 'Fecha de Transacción', boleta.fechaCompleta),

            const Divider(height: 30),

            /// Detalles del Pago.
            Text('Método de Pago:', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildDetailRow(context, 'Tarjeta',
                '${boleta.tipoTarjeta} terminada en **** ${boleta.ultimosCuatroDigitos}'),

            const Divider(height: 30),

            /// Total.
            _buildDetailRow(context, 'Subtotal', 'S/ ${boleta.montoPagado}'),
            _buildDetailRow(context, 'IGV (18%)', 'Incluido'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Pagado',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  'S/ ${boleta.montoPagado}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}