import 'package:flutter/material.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/models/perfil_model.dart';

/// {@template insignia_estatus_widget}
/// Widget de tarjeta que muestra el estatus principal del usuario en la pantalla de perfil.
///
/// Determina el icono, color, nombre y descripción del estatus basándose en el
/// rol del usuario ([AuthNotifier.userRole]) y su plan de suscripción ([Perfil.nombrePlan]).
/// Muestra estatus como 'Administrador', 'Líder Vecinal', 'Reportero de Prensa',
/// 'Guardián Premium' o 'Ciudadano'.
/// {@endtemplate}
class InsigniaEstatusWidget extends StatelessWidget {
  /// Los datos del perfil del usuario, necesarios para obtener el nombre del plan.
  final Perfil perfil;

  /// {@macro insignia_estatus_widget}
  const InsigniaEstatusWidget({super.key, required this.perfil});

  /// Determina el [IconData] a mostrar según el rol y plan.
  IconData _obtenerIcono(String? rol, String? planNombre) {
    if (rol == 'admin') {
      return Icons.admin_panel_settings_rounded;
    }
    if (rol == 'lider_vecinal') {
      return Icons.security_rounded;
    }
    if (rol == 'reportero') {
      return Icons.assignment_ind_rounded;
    }
    if (planNombre != null && planNombre.toLowerCase().contains('premium')) {
      return Icons.shield_rounded; // Icono premium
    }
    return Icons.person_rounded; // Icono de ciudadano estándar
  }

  /// Determina el color principal asociado al estatus.
  Color _obtenerColor(String? rol, String? planNombre, ThemeData theme) {
    if (rol == 'admin') {
      return Colors.red.shade700;
    }
    if (rol == 'lider_vecinal') {
      return theme.colorScheme.primary; // Color primario del tema
    }
    if (rol == 'reportero') {
      return Colors.blue.shade700;
    }
    if (planNombre != null && planNombre.toLowerCase().contains('premium')) {
      return Colors.amber.shade700; // Color ámbar para premium
    }
    return theme.colorScheme.secondary; // Color secundario para ciudadano
  }

  /// Devuelve el nombre legible del estatus.
  String _obtenerEstatus(String? rol, String? planNombre) {
    if (rol == 'admin') {
      return 'Administrador';
    }
    if (rol == 'lider_vecinal') {
      return 'Líder Vecinal';
    }
    if (rol == 'reportero') {
      return 'Reportero de Prensa';
    }
    if (planNombre != null && planNombre.toLowerCase().contains('premium')) {
      return 'Guardián Premium';
    }
    return 'Ciudadano';
  }

  /// Devuelve una breve descripción asociada al estatus.
  String _obtenerDescripcion(String? rol, String? planNombre) {
    if (rol == 'admin') {
      return 'Acceso total al sistema.';
    }
    if (rol == 'lider_vecinal') {
      return 'Validando y gestionando reportes de tu zona.';
    }
    if (rol == 'reportero') {
      return 'Usuario de prensa verificado.';
    }
    if (planNombre != null && planNombre.toLowerCase().contains('premium')) {
      return 'Apoyando activamente a la comunidad.';
    }
    return 'Participando en la comunidad.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Observa cambios en el AuthNotifier para obtener el rol actualizado.
    final auth = context.watch<AuthNotifier>();
    final planNombre = perfil.nombrePlan; // Nombre del plan desde el perfil cargado.
    final rol = auth.userRole; // Rol desde el AuthNotifier.

    // Obtiene los detalles visuales y textuales del estatus.
    final String estatusNombre = _obtenerEstatus(rol, planNombre);
    final String estatusDesc = _obtenerDescripcion(rol, planNombre);
    final IconData estatusIcono = _obtenerIcono(rol, planNombre);
    final Color estatusColor = _obtenerColor(rol, planNombre, theme);

    // Construye la tarjeta.
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            /// Avatar con el icono y color del estatus.
            CircleAvatar(
              radius: 24,
              backgroundColor: estatusColor.withAlpha(38), // Fondo semitransparente.
              child: Icon(
                estatusIcono,
                color: estatusColor, // Icono con el color principal.
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            /// Columna con el nombre y descripción del estatus.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estatus Actual',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  Text(
                    estatusNombre,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    estatusDesc,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2, // Limita a 2 líneas.
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}