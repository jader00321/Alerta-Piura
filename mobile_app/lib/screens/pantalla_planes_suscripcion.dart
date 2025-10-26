import 'package:flutter/material.dart';
import 'package:mobile_app/api/servicio_suscripcion.dart';
import 'package:mobile_app/models/plan_suscripcion_model.dart';
import 'package:mobile_app/screens/pantalla_pago.dart'; // <-- IMPORT THE NEW PAYMENT SCREEN
import 'package:mobile_app/widgets/esqueletos/esqueleto_lista_planes.dart';
import 'package:mobile_app/widgets/planes/tarjeta_plan.dart';

class PantallaPlanesSuscripcion extends StatefulWidget {
  const PantallaPlanesSuscripcion({super.key});

  @override
  State<PantallaPlanesSuscripcion> createState() =>
      _PantallaPlanesSuscripcionState();
}

class _PantallaPlanesSuscripcionState extends State<PantallaPlanesSuscripcion> {
  late Future<List<PlanSuscripcion>> _plansFuture;
  final ServicioSuscripcion _servicioSuscripcion = ServicioSuscripcion();

  @override
  void initState() {
    super.initState();
    _plansFuture = _servicioSuscripcion.getPlanes();
  }

  // --- UPDATED NAVIGATION LOGIC ---
  void _navigateToPayment(PlanSuscripcion plan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaPago(
            plan: plan), // Navigate to the functional payment screen
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planes Premium'),
      ),
      body: FutureBuilder<List<PlanSuscripcion>>(
        future: _plansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const EsqueletoListaPlanes();
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar los planes: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay planes de suscripción disponibles.'),
            );
          }

          final planes = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: planes.length,
            itemBuilder: (context, index) {
              final plan = planes[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TarjetaPlan(
                  plan: plan,
                  onSelected: () => _navigateToPayment(plan),
                  isRecommended: index == 0,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
