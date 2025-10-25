import 'package:flutter/material.dart';
import 'package:mobile_app/api/perfil_service.dart';
import 'package:mobile_app/models/boleta_detalle_model.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_detalle_boleta.dart';
import 'package:mobile_app/widgets/boletas/tarjeta_detalle_boleta.dart';

class PantallaDetalleBoleta extends StatefulWidget {
  final String transactionId;
  const PantallaDetalleBoleta({super.key, required this.transactionId});

  @override
  State<PantallaDetalleBoleta> createState() => _PantallaDetalleBoletaState();
}

class _PantallaDetalleBoletaState extends State<PantallaDetalleBoleta> {
  late Future<BoletaDetalle> _boletaFuture;
  final PerfilService _perfilService = PerfilService();

  @override
  void initState() {
    super.initState();
    _boletaFuture = _perfilService.getDetalleBoleta(widget.transactionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de la Boleta'),
      ),
      body: FutureBuilder<BoletaDetalle>(
        future: _boletaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const EsqueletoDetalleBoleta();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar la boleta: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No se encontraron los detalles de la transacción.'));
          }

          final boleta = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: TarjetaDetalleBoleta(boleta: boleta),
          );
        },
      ),
    );
  }
}