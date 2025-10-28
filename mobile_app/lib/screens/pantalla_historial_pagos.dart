import 'package:flutter/material.dart';
import 'package:mobile_app/api/perfil_service.dart';
import 'package:mobile_app/models/historial_pago_model.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_historial_pagos.dart';
import 'package:mobile_app/widgets/historial_pagos/tarjeta_historial_pago.dart';

/// {@template pantalla_historial_pagos}
/// Pantalla que muestra el historial de transacciones de pago del usuario.
///
/// Utiliza [PerfilService.getHistorialPagos] para obtener la lista de [HistorialPago].
/// Cada elemento de la lista es renderizado por [TarjetaHistorialPago] y es
/// tappable para navegar a [PantallaDetalleBoleta].
/// {@endtemplate}
class PantallaHistorialPagos extends StatefulWidget {
  /// {@macro pantalla_historial_pagos}
  const PantallaHistorialPagos({super.key});

  @override
  State<PantallaHistorialPagos> createState() =>
      _PantallaHistorialPagosState();
}

/// Estado para [PantallaHistorialPagos].
///
/// Maneja la carga y actualización del historial de pagos.
class _PantallaHistorialPagosState extends State<PantallaHistorialPagos> {
  /// Futuro que contiene la lista del historial de pagos.
  late Future<List<HistorialPago>> _historialFuture;
  final PerfilService _perfilService = PerfilService();

  @override
  void initState() {
    super.initState();
    _historialFuture = _perfilService.getHistorialPagos();
  }

  /// Recarga el historial de pagos desde la API.
  Future<void> _refreshHistorial() async {
    setState(() {
      _historialFuture = _perfilService.getHistorialPagos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Pagos'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshHistorial,
        child: FutureBuilder<List<HistorialPago>>(
          future: _historialFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const EsqueletoHistorialPagos();
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text('Error al cargar el historial: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'No has realizado ninguna transacción todavía.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              );
            }

            final historial = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: historial.length,
              itemBuilder: (context, index) {
                final pago = historial[index];
                return TarjetaHistorialPago(
                  pago: pago,
                  onTap: () {
                    // Navega a la pantalla de detalle de la boleta
                    Navigator.pushNamed(context, '/detalle_boleta',
                        arguments: pago.id);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}