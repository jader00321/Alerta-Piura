import 'package:flutter/material.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// {@template acciones_mapa}
/// Widget que agrupa y muestra los botones de acción flotantes (FAB)
/// sobre la pantalla del [MapaView].
///
/// Modificaciones:
/// - El botón "Reportar" ahora es siempre visible.
/// {@endtemplate}
class AccionesMapa extends StatelessWidget {
  final VoidCallback onShowFilterSheet;
  final VoidCallback onCenterOnUser;
  final VoidCallback onSetDefaultLocation;
  final VoidCallback onLongPressDefaultLocation;
  final VoidCallback onCreateReport;
  final VoidCallback onOpenSettings; 

  // Estado SOS
  final bool isSosActive;
  final int sosRemainingSeconds;
  final VoidCallback onActivateSos;
  final VoidCallback onDeactivateSos;

  const AccionesMapa({
    super.key,
    required this.onShowFilterSheet,
    required this.onCenterOnUser,
    required this.onSetDefaultLocation,
    required this.onLongPressDefaultLocation,
    required this.onCreateReport,
    required this.onOpenSettings,
    required this.isSosActive,
    required this.sosRemainingSeconds,
    required this.onActivateSos,
    required this.onDeactivateSos,
  });

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();
    final bool canActivateSos = authNotifier.isAuthenticated && authNotifier.isPremium;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // --- Fila Superior de Herramientas ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Columna Izquierda (Filtros y Config)
                  Column(
                    children: [
                       FloatingActionButton.small(
                        heroTag: 'filter_btn',
                        onPressed: onShowFilterSheet,
                        child: const Icon(Icons.filter_list),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'settings_btn',
                        onPressed: onOpenSettings,
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.settings, color: Colors.grey),
                      ),
                    ],
                  ),
                 
                  // Columna Derecha (Ubicación y Casa)
                  Column(
                    children: [
                      GestureDetector(
                        onLongPress: onLongPressDefaultLocation,
                        child: FloatingActionButton.small(
                          heroTag: 'set_default_loc_btn',
                          onPressed: onSetDefaultLocation,
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.teal.shade700,
                          child: const Icon(Icons.home_filled),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'location_btn',
                        onPressed: onCenterOnUser,
                        child: const Icon(Icons.my_location),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- Fila Inferior (Reportar y SOS) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // --- BOTÓN REPORTAR (SIEMPRE VISIBLE) ---
              FloatingActionButton.extended(
                heroTag: 'create_report_btn',
                onPressed: onCreateReport,
                icon: const Icon(Icons.add),
                label: const Text('Reportar'),
              ),

              // --- BOTÓN SOS ---
              GestureDetector(
                onTap: () {
                  if (!canActivateSos) {
                     showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Función Premium'),
                          content: const Text('La Alerta SOS es una función exclusiva.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
                            ElevatedButton(
                                onPressed: () { Navigator.pop(ctx); Navigator.pushNamed(context, '/subscription_plans'); },
                                child: const Text('Ver Planes')),
                          ],
                        ),
                      );
                  } else if (isSosActive) {
                     onDeactivateSos(); 
                  } else {
                     onActivateSos();
                  }
                },
                child: FloatingActionButton(
                  heroTag: 'sos_btn',
                  onPressed: null, 
                  backgroundColor: isSosActive ? Colors.red.shade900 : (canActivateSos ? Colors.red : Colors.grey),
                  shape: isSosActive 
                      ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.white, width: 2)) 
                      : const CircleBorder(),
                  child: isSosActive
                      ? Container(
                          padding: const EdgeInsets.all(4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                              Text(
                                '${(sosRemainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(sosRemainingSeconds % 60).toString().padLeft(2, '0')}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 10),
                              )
                            ],
                          ),
                        )
                      : const Icon(Icons.sos, color: Colors.white, size: 32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}