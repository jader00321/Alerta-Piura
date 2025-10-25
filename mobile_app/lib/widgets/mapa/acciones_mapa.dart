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
  
  // --- Parámetros SOS Simplificados ---
  final bool isSosActive;
  final int sosRemainingSeconds;
  final VoidCallback onActivateSos; // <--- NUEVO
  final VoidCallback onDeactivateSos;
  
  // --- ELIMINADOS ---
  // final double sosHoldProgress; 
  // final Animation<double> sosActiveAnimation;
  // final Function(LongPressStartDetails) onSosPressStart;
  // final Function(LongPressEndDetails) onSosPressEnd;


  const AccionesMapa({
    super.key,
    required this.onToggleHeatmap,
    required this.isHeatmapVisible,
    required this.onShowFilterSheet,
    required this.onCenterOnUser,
    required this.onCreateReport,
    required this.isSosActive,
    required this.sosRemainingSeconds,
    required this.onActivateSos, // <--- NUEVO
    required this.onDeactivateSos,
    // --- ELIMINADOS DEL CONSTRUCTOR ---
    // required this.sosHoldProgress,
    // required this.sosActiveAnimation,
    // required this.onSosPressStart,
    // required this.onSosPressEnd,
  });

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();
    // Determina si el usuario puede activar el SOS (autenticado y premium)
    final bool canActivateSos = authNotifier.isAuthenticated && authNotifier.isPremium;
    
    // --- ELIMINADO 'isHoldingSos' ---

    return Padding(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // --- Botones de la Izquierda (SIN CAMBIOS) ---
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
                  child: Icon(
                    Icons.layers,
                    color: isHeatmapVisible ? Theme.of(context).colorScheme.onPrimary : null
                  ),
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

          // --- Botones de la Derecha (SOS MODIFICADO) ---
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

              // --- WIDGET SOS SIMPLIFICADO ---
              if (authNotifier.isAuthenticated)
                GestureDetector(
                  // --- LÓGICA DE TAP SIMPLIFICADA ---
                  onTap: () {
                     // Caso 1: SOS está activo. Tocar desactiva.
                     if (isSosActive) {
                       if (canActivateSos) { // Si es premium (debería serlo si está activo)
                         onDeactivateSos();
                       }
                     } 
                     // Caso 2: SOS está inactivo. Tocar activa (si es premium) o muestra planes.
                     else {
                       if (canActivateSos) {
                         // Es premium -> Activar SOS
                         onActivateSos(); 
                       }
                       else if (authNotifier.isAuthenticated) {
                         // No es premium -> Ir a planes
                         Navigator.pushNamed(context, '/subscription_plans');
                       }
                     }
                  },
                  // --- ELIMINADOS onLongPressStart y onLongPressEnd ---
                  child: FloatingActionButton(
                    heroTag: 'sos_btn',
                    onPressed: null, // GestureDector maneja los taps
                    
                    // --- Color de fondo SIMPLIFICADO ---
                    backgroundColor: isSosActive
                        ? Colors.red // Rojo brillante si SOS está activo
                        : canActivateSos
                            ? Colors.red.shade300 // Rojo claro si es premium y listo
                            : Colors.grey, // Gris si no es premium
                            
                    tooltip: canActivateSos
                        ? (isSosActive ? 'Finalizar Alerta' : 'Presiona para SOS') // Tooltip actualizado
                        : 'Activa Premium para usar SOS',
                    child: isSosActive
                        ? Text( // Mostrar contador
                            '${(sosRemainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(sosRemainingSeconds % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)
                          )
                        : const Icon(Icons.sos, color: Colors.white, size: 28),
                  ),
                ),
               // --- Fin Widget SOS ---
            ],
          ),
        ],
      ),
    );
  }
}