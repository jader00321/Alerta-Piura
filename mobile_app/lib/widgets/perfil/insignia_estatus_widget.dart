// lib/widgets/perfil/insignia_estatus_widget.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/models/perfil_model.dart'; // Para leer el nombre del plan

class InsigniaEstatusWidget extends StatelessWidget {
  // Ya no necesita la lista de insignias
  final Perfil perfil;

  const InsigniaEstatusWidget({super.key, required this.perfil});

  // Función para obtener el icono basado en el 'icono_url' o rol
  IconData _obtenerIcono(String? rol, String? planNombre) {
    if (rol == 'admin') return Icons.admin_panel_settings_rounded;
    if (rol == 'lider_vecinal') return Icons.security_rounded;
    if (rol == 'reportero') return Icons.assignment_ind_rounded;
    if (planNombre != null && planNombre.toLowerCase().contains('premium')) return Icons.shield_rounded;
    return Icons.person_rounded; // Icono de ciudadano estándar
  }

  // Función para obtener el color del icono
  Color _obtenerColor(String? rol, String? planNombre, ThemeData theme) {
    if (rol == 'admin') return Colors.red.shade700;
    if (rol == 'lider_vecinal') return theme.colorScheme.primary;
    if (rol == 'reportero') return Colors.blue.shade700;
    if (planNombre != null && planNombre.toLowerCase().contains('premium')) return Colors.amber.shade700;
    return theme.colorScheme.secondary;
  }
  
  // Función para obtener el texto del estatus
  String _obtenerEstatus(String? rol, String? planNombre) {
    if (rol == 'admin') return 'Administrador';
    if (rol == 'lider_vecinal') return 'Líder Vecinal';
    if (rol == 'reportero') return 'Reportero de Prensa';
    if (planNombre != null && planNombre.toLowerCase().contains('premium')) return 'Guardián Premium';
    return 'Ciudadano';
  }

  // Función para obtener la descripción del estatus
  String _obtenerDescripcion(String? rol, String? planNombre) {
     if (rol == 'admin') return 'Acceso total al sistema.';
     if (rol == 'lider_vecinal') return 'Validando y gestionando reportes de tu zona.';
     if (rol == 'reportero') return 'Usuario de prensa verificado.';
     if (planNombre != null && planNombre.toLowerCase().contains('premium')) return 'Apoyando activamente a la comunidad.';
     return 'Participando en la comunidad.';
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Leer el AuthNotifier para obtener el 'rol'
    final auth = context.watch<AuthNotifier>();
    final planNombre = perfil.nombrePlan;
    final rol = auth.userRole;

    // Determinar los detalles del estatus
    final String estatusNombre = _obtenerEstatus(rol, planNombre);
    final String estatusDesc = _obtenerDescripcion(rol, planNombre);
    final IconData estatusIcono = _obtenerIcono(rol, planNombre);
    final Color estatusColor = _obtenerColor(rol, planNombre, theme);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: estatusColor.withOpacity(0.15),
              child: Icon(
                estatusIcono,
                color: estatusColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estatus Actual',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  Text(
                    estatusNombre,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    estatusDesc,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
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