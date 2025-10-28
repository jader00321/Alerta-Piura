import 'package:flutter/material.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// {@template acciones_mapa}
/// Widget que agrupa y muestra los botones de acción flotantes (FAB)
/// sobre la pantalla del [MapaView].
///
/// Incluye botones para:
/// - Mostrar filtros ([onShowFilterSheet])
/// - Centrar en la ubicación del usuario ([onCenterOnUser])
/// - Crear un nuevo reporte ([onCreateReport])
/// - Activar/Desactivar la Alerta SOS ([onActivateSos], [onDeactivateSos])
///
/// El botón SOS es dinámico: cambia de color, muestra un temporizador
/// ([sosRemainingSeconds]) y su acción depende de si la alerta está
/// activa ([isSosActive]) o si el usuario puede activarla ([AuthNotifier.canUseSos]).
/// {@endtemplate}
class AccionesMapa extends StatelessWidget {
  /// Callback para mostrar el panel de filtros.
  final VoidCallback onShowFilterSheet;
  /// Callback para centrar el mapa en la ubicación del usuario.
  final VoidCallback onCenterOnUser;
  /// Callback para navegar a la pantalla de creación de reporte.
  final VoidCallback onCreateReport;
  /// Indica si la alerta SOS está actualmente activa.
  final bool isSosActive;
  /// Segundos restantes de la alerta SOS activa (para el temporizador).
  final int sosRemainingSeconds;
  /// Callback para iniciar la activación de la alerta SOS.
  final VoidCallback onActivateSos;
  /// Callback para mostrar el diálogo de desactivación de SOS.
  final VoidCallback onDeactivateSos;

  /// {@macro acciones_mapa}
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
    /// Determina si el usuario tiene permiso para usar SOS (Premium o Reportero).
    final bool canActivateSos = authNotifier.isAuthenticated && authNotifier.isPremium;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          /// Fila superior de botones (Filtros, Ubicación)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FloatingActionButton.small(
                heroTag: 'filter_btn',
                onPressed: onShowFilterSheet,
                child: const Icon(Icons.filter_list),
              ),
              FloatingActionButton.small(
                heroTag: 'location_btn',
                onPressed: onCenterOnUser,
                child: const Icon(Icons.my_location),
              ),
            ],
          ),
          const SizedBox(height: 16),
          /// Fila inferior de botones (Crear Reporte, SOS)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                heroTag: 'create_report_btn',
                onPressed: onCreateReport,
                icon: const Icon(Icons.add),
                label: const Text('Reportar'),
              ),
              /// Widget dinámico del botón SOS
              GestureDetector(
                /// Usa un solo tap para activar o desactivar.
                onTap: canActivateSos ? (isSosActive ? onDeactivateSos : onActivateSos) : () {
                  // Si no puede activar, muestra diálogo para ir a planes.
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Función Premium'),
                      content: const Text('La Alerta SOS es una función premium. ¿Deseas ver los planes?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                        ElevatedButton(onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.pushNamed(context, '/subscription_plans');
                        }, child: const Text('Ver Planes')),
                      ],
                    ),
                  );
                },
                child: FloatingActionButton(
                  heroTag: 'sos_btn',
                  onPressed: null, // El GestureDetector maneja el tap.
                  /// Color dinámico basado en el estado.
                  backgroundColor: isSosActive
                      ? Colors.red // Activo
                      : canActivateSos
                          ? Colors.red.shade300 // Listo para activar
                          : Colors.grey, // Deshabilitado (no premium)
                  tooltip: canActivateSos
                      ? (isSosActive ? 'Finalizar Alerta' : 'Presiona para SOS')
                      : 'Activa Premium para usar SOS',
                  /// Contenido dinámico (Icono o Temporizador).
                  child: isSosActive
                      ? Text(
                          /// Formatea los segundos restantes a MM:SS
                          '${(sosRemainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(sosRemainingSeconds % 60).toString().padLeft(2, '0')}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16),
                        )
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