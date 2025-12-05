import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobile_app/api/perfil_service.dart';
import 'package:mobile_app/models/historial_pago_model.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_historial_pagos.dart';
import 'package:mobile_app/widgets/historial_pagos/tarjeta_historial_pago.dart';

/// {@template pantalla_historial_pagos}
/// Pantalla que muestra el historial de transacciones con una vista previa limitada.
///
/// Muestra inicialmente solo los últimos 5 pagos para no saturar la vista.
/// Incluye un botón "Ver historial completo" para expandir la lista.
/// {@endtemplate}
class PantallaHistorialPagos extends StatefulWidget {
  const PantallaHistorialPagos({super.key});

  @override
  State<PantallaHistorialPagos> createState() => _PantallaHistorialPagosState();
}

class _PantallaHistorialPagosState extends State<PantallaHistorialPagos> {
  late Future<List<HistorialPago>> _historialFuture;
  final PerfilService _perfilService = PerfilService();
  
  // Estado para controlar si se muestra toda la lista o solo el resumen.
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _historialFuture = _perfilService.getHistorialPagos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Pagos'),
        elevation: 0,
      ),
      body: FutureBuilder<List<HistorialPago>>(
        future: _historialFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const EsqueletoHistorialPagos();
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('No se pudo cargar el historial.'),
                  TextButton(
                    onPressed: () => setState(() {
                      _historialFuture = _perfilService.getHistorialPagos();
                    }),
                    child: const Text('Reintentar'),
                  )
                ],
              ),
            );
          }

          final historial = snapshot.data!;

          if (historial.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes transacciones registradas.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // Determinar cuántos ítems mostrar
          final int itemCount = _showAll ? historial.length : min(historial.length, 5);
          final bool hasMore = historial.length > 5;

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: itemCount + (hasMore && !_showAll ? 1 : 0), // +1 para el botón
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              // Si es el último ítem y hay más por mostrar, renderizamos el botón
              if (hasMore && !_showAll && index == itemCount) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextButton.icon(
                    onPressed: () => setState(() => _showAll = true),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    label: Text('Ver ${historial.length - 5} transacciones más'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                );
              }

              final pago = historial[index];
              return TarjetaHistorialPago(
                pago: pago,
                onTap: () {
                  Navigator.pushNamed(context, '/detalle_boleta', arguments: pago.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}