import 'package:flutter/material.dart';
import 'package:mobile_app/models/plan_suscripcion_model.dart';

/// {@template tarjeta_plan}
/// Widget de tarjeta que muestra los detalles de un [PlanSuscripcion] disponible.
///
/// Muestra el nombre, precio, lista de características (parseadas desde [plan.descripcion])
/// y un botón para seleccionar el plan. Puede mostrar opcionalmente un chip "Recomendado".
/// Utilizado en [PantallaPlanesSuscripcion].
/// {@endtemplate}
class TarjetaPlan extends StatelessWidget {
  /// Los datos del plan de suscripción a mostrar.
  final PlanSuscripcion plan;
  /// Callback que se ejecuta al presionar el botón "Seleccionar Plan".
  final VoidCallback onSelected;
  /// Si es `true`, muestra un chip "Recomendado" en la tarjeta.
  final bool isRecommended;

  /// {@macro tarjeta_plan}
  const TarjetaPlan({
    super.key,
    required this.plan,
    required this.onSelected,
    this.isRecommended = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Parsea la descripción para obtener la lista de características.
    // Maneja saltos de línea `\n` y `\\n` y elimina líneas vacías.
    final features = plan.descripcion
            ?.split(RegExp(r'\\n|\n')) // Divide por \n o \\n
            .where((s) => s.trim().isNotEmpty) // Elimina líneas vacías
            .toList() ??
        []; // Lista vacía si la descripción es null

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        // Añade un borde resaltado si es el plan recomendado.
        side: BorderSide(
          color: isRecommended ? theme.colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Chip "Recomendado" (opcional).
            if (isRecommended)
              Chip(
                label: const Text('Recomendado'),
                backgroundColor: theme.colorScheme.primary,
                labelStyle: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              ),
            if (isRecommended) const SizedBox(height: 8),

            /// Nombre del Plan.
            Text(
              plan.nombrePublico,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            /// Precio Mensual.
            Text(
              'S/ ${plan.precioMensual} / mes',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 32),

            /// Lista de Características.
            if (features.isEmpty)
              const Text('No hay beneficios detallados.')
            else
              // Construye la lista de características con iconos.
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: features
                    .map((feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle_outline,
                                  color: Colors.green.shade600, size: 20),
                              const SizedBox(width: 12),
                              // Limpia guiones y espacios extra al inicio de la característica.
                              Expanded(
                                  child: Text(
                                      feature.trim().replaceFirst('- ', ''))),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 16),

            /// Botón para seleccionar el plan.
            ElevatedButton(
              onPressed: onSelected, // Llama al callback del padre.
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // Botón ancho.
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Seleccionar Plan'),
            ),
          ],
        ),
      ),
    );
  }
}