import 'package:flutter/material.dart';
import 'package:mobile_app/models/boleta_detalle_model.dart';

/// {@template tarjeta_detalle_boleta}
/// Widget rediseñado que muestra el detalle de una transacción como un recibo digital.
/// Incluye un sello visual de "PAGADO / APROBADO".
/// {@endtemplate}
class TarjetaDetalleBoleta extends StatelessWidget {
  final BoletaDetalle boleta;

  const TarjetaDetalleBoleta({super.key, required this.boleta});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- Cabecera con Icono ---
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.receipt_long, color: theme.colorScheme.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Boleta de Venta',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'ID: ${boleta.id.substring(0, 8).toUpperCase()}',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),

            // --- SELLO DE APROBADO (NUEVO) ---
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text(
                      "PAGO APROBADO",
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 40),

            // --- Detalles del Cliente ---
            _buildSectionTitle(context, 'Información del Cliente'),
            _buildDetailRow(context, 'Titular', boleta.nombreUsuario),
            _buildDetailRow(context, 'Email', boleta.emailUsuario),

            const SizedBox(height: 20),

            // --- Detalles del Servicio ---
            _buildSectionTitle(context, 'Detalle del Servicio'),
            _buildDetailRow(context, 'Plan', boleta.nombrePlan),
            _buildDetailRow(context, 'Fecha', boleta.fechaCompleta),
            _buildDetailRow(context, 'Pasarela ID', boleta.idTransaccionPasarela, isMono: true),

            const SizedBox(height: 20),

            // --- Método de Pago ---
            _buildSectionTitle(context, 'Método de Pago'),
            Row(
              children: [
                Icon(Icons.credit_card, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '${boleta.tipoTarjeta} •••• ${boleta.ultimosCuatroDigitos}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),

            const Divider(height: 40),

            // --- Totales ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Pagado', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[700])),
                Text(
                  'S/ ${boleta.montoPagado}',
                  style: theme.textTheme.headlineSmall?.copyWith(
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

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.secondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isMono = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: isMono ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}