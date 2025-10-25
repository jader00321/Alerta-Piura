// lib/widgets/mapa/acciones_mapa.dart

import 'package:flutter/material.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AccionesMapa extends StatelessWidget {
  final VoidCallback onToggleHeatmap;
  final bool isHeatmapVisible;
  final VoidCallback onShowFilterSheet;
  final VoidCallback onCenterOnUser;
  final VoidCallback onCreateReport;
  final bool isSosActive;
  final int sosRemainingSeconds;
  final Function(LongPressStartDetails) onSosPressStart;
  final Function(LongPressEndDetails) onSosPressEnd;
  final VoidCallback onDeactivateSos;

  const AccionesMapa({
    super.key,
    required this.onToggleHeatmap,
    required this.isHeatmapVisible,
    required this.onShowFilterSheet,
    required this.onCenterOnUser,
    required this.onCreateReport,
    required this.isSosActive,
    required this.sosRemainingSeconds,
    required this.onSosPressStart,
    required this.onSosPressEnd,
    required this.onDeactivateSos,
  });

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Botones de la izquierda
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'layers_btn',
                  onPressed: onToggleHeatmap,
                  tooltip: 'Capas del Mapa',
                  backgroundColor: isHeatmapVisible ? Theme.of(context).colorScheme.primary : null,
                  child: Icon(Icons.layers, color: isHeatmapVisible ? Theme.of(context).colorScheme.onPrimary : null),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'filter_btn',
                  onPressed: onShowFilterSheet,
                  tooltip: 'Filtros',
                  child: const Icon(Icons.filter_list),
                ),
              ],
            )
          ),

          // Botones de la derecha
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: 'my_location_btn',
                onPressed: onCenterOnUser,
                tooltip: 'Mi Ubicación',
                child: const Icon(Icons.my_location),
              ),
              const SizedBox(height: 16),
              FloatingActionButton.extended(
                heroTag: 'create_report_btn',
                onPressed: onCreateReport,
                label: const Text('Reportar'),
                //icon: const Icon(Icons.add),
              ),
              const SizedBox(height: 16),
              if (authNotifier.isAuthenticated)
                GestureDetector(
                  onLongPressStart: authNotifier.isPremium && !isSosActive ? onSosPressStart : null,
                  onLongPressEnd: authNotifier.isPremium && !isSosActive ? onSosPressEnd : null,
                  onTap: authNotifier.isPremium && isSosActive ? onDeactivateSos : () {
                    if (!authNotifier.isPremium) {
                      Navigator.pushNamed(context, '/subscription_plans');
                    }
                  },
                  child: FloatingActionButton(
                    heroTag: 'sos_btn',
                    onPressed: null,
                    backgroundColor: isSosActive ? Colors.red : (authNotifier.isPremium ? Colors.red.shade300 : Colors.grey),
                    tooltip: authNotifier.isPremium ? (isSosActive ? 'Finalizar Alerta' : 'Mantén presionado') : 'Función Premium',
                    child: isSosActive
                        ? Text('${(sosRemainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(sosRemainingSeconds % 60).toString().padLeft(2, '0')}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
                        : const Icon(Icons.sos, color: Colors.white),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}