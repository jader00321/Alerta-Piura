// lib/widgets/mapa/acciones_mapa.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AccionesMapa extends StatelessWidget {
  final VoidCallback onShowFilterSheet;
  final VoidCallback onCenterOnUser;
  final VoidCallback onCreateReport;

  final bool isSosActive;
  final int sosRemainingSeconds;
  final VoidCallback onActivateSos;
  final VoidCallback onDeactivateSos;

  const AccionesMapa({
    super.key,
    required this.onShowFilterSheet,
    required this.onCenterOnUser,
    required this.onCreateReport,
    required this.isSosActive,
    required this.sosRemainingSeconds,
    required this.onActivateSos,
    required this.onDeactivateSos,
  });

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();
    final bool canActivateSos =
        authNotifier.isAuthenticated && authNotifier.isPremium;

    return Padding(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    heroTag: 'filter_btn',
                    onPressed: onShowFilterSheet,
                    tooltip: 'Filtros',
                    child: const Icon(Icons.filter_list),
                  ),
                ],
              )),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón de Mi Ubicación
              FloatingActionButton(
                heroTag: 'my_location_btn',
                onPressed: onCenterOnUser,
                tooltip: 'Mi Ubicación',
                child: const Icon(Icons.my_location),
              ),
              const SizedBox(height: 16),
              // Botón Extendido de Reportar
              FloatingActionButton.extended(
                heroTag: 'create_report_btn',
                onPressed: onCreateReport,
                label: const Text('Reportar'),
                icon: const Icon(Icons.add),
              ),
              const SizedBox(height: 16),

              if (authNotifier.isAuthenticated)
                GestureDetector(
                  onTap: () {
                    // Caso 1: SOS está activo. Tocar desactiva.
                    if (isSosActive) {
                      if (canActivateSos) {
                        // Si es premium (debería serlo si está activo)
                        onDeactivateSos();
                      }
                    }
                    // Caso 2: SOS está inactivo. Tocar activa (si es premium) o muestra planes.
                    else {
                      if (canActivateSos) {
                        // Es premium -> Activar SOS
                        onActivateSos();
                      } else if (authNotifier.isAuthenticated) {
                        // No es premium -> Ir a planes
                        Navigator.pushNamed(context, '/subscription_plans');
                      }
                    }
                  },
                  child: FloatingActionButton(
                    heroTag: 'sos_btn',
                    onPressed: null,

                    backgroundColor: isSosActive
                        ? Colors.red
                        : canActivateSos
                            ? Colors.red
                                .shade300 // Rojo claro si es premium y listo
                            : Colors.grey, // Gris si no es premium

                    tooltip: canActivateSos
                        ? (isSosActive
                            ? 'Finalizar Alerta'
                            : 'Presiona para SOS') // Tooltip actualizado
                        : 'Activa Premium para usar SOS',
                    child: isSosActive
                        ? Text(
                            // Mostrar contador
                            '${(sosRemainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(sosRemainingSeconds % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16))
                        : const Icon(Icons.sos, color: Colors.white, size: 28),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
