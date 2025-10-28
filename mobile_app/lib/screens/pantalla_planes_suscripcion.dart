import 'package:flutter/material.dart';
import 'package:mobile_app/api/servicio_suscripcion.dart';
import 'package:mobile_app/models/plan_suscripcion_model.dart';
import 'package:mobile_app/screens/pantalla_pago.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_lista_planes.dart';
import 'package:mobile_app/widgets/planes/tarjeta_plan.dart';

/// {@template pantalla_planes_suscripcion}
/// Pantalla que muestra los planes de suscripción premium disponibles.
///
/// Obtiene los planes de [ServicioSuscripcion.getPlanes] y los muestra
/// usando [TarjetaPlan]. Al seleccionar un plan, navega a [PantallaPago].
/// {@endtemplate}
class PantallaPlanesSuscripcion extends StatefulWidget {
  /// {@macro pantalla_planes_suscripcion}
  const PantallaPlanesSuscripcion({super.key});

  @override
  State<PantallaPlanesSuscripcion> createState() =>
      _PantallaPlanesSuscripcionState();
}

/// Estado para [PantallaPlanesSuscripcion].
///
/// Maneja la carga de los planes disponibles.
class _PantallaPlanesSuscripcionState
    extends State<PantallaPlanesSuscripcion> {
  /// Futuro que contiene la lista de planes de suscripción.
  late Future<List<PlanSuscripcion>> _plansFuture;
  final ServicioSuscripcion _servicioSuscripcion = ServicioSuscripcion();

  @override
  void initState() {
    super.initState();
    _plansFuture = _servicioSuscripcion.getPlanes();
  }

  /// Navega a la pantalla de pago [PantallaPago] pasando el [plan] seleccionado.
  void _navigateToPayment(PlanSuscripcion plan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaPago(plan: plan),
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
                  // Marca el primer plan (generalmente el más barato) como recomendado
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