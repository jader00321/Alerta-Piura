// lib/screens/perfil_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/api/perfil_service.dart';
import 'package:mobile_app/models/perfil_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_perfil.dart';
import 'package:mobile_app/widgets/perfil/perfil_header_card.dart';
import 'package:mobile_app/widgets/perfil/perfil_action_tile.dart';
import 'package:mobile_app/widgets/perfil/dialogo_postulacion_lider.dart';
import 'package:mobile_app/widgets/perfil/insignia_estatus_widget.dart'; 
import 'package:provider/provider.dart';


class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final PerfilService _perfilService = PerfilService();
  late Future<Perfil> _perfilFuture;

  @override
  void initState() {
    super.initState();
    _perfilFuture = _perfilService.getMiPerfil();
  }

  Future<void> _refreshProfile() async {
    if (mounted) {
      await context.read<AuthNotifier>().refreshUserStatus();
    }
    if (mounted) {
      setState(() {
        _perfilFuture = _perfilService.getMiPerfil();
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(child: const Text('No'), onPressed: () => Navigator.pop(ctx, false)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, Cerrar Sesión'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<AuthNotifier>().logout();
      if (mounted) {
         Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    }
  }

  Future<void> _handlePostularLider() async {
     final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const DialogoPostulacionLider(),
    );
    if (result == true && mounted) {
      _refreshProfile(); 
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Tu postulación ha sido enviada.'),
        backgroundColor: Colors.green,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>(); 
    final theme = Theme.of(context);

    return Scaffold(
      // --- CORRECCIÓN DE ESPACIADO ---
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        // Quitar 'extendBodyBehindAppBar' del Scaffold
      ),
      // --- FIN CORRECCIÓN ---
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: FutureBuilder<Perfil>(
          future: _perfilFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const EsqueletoPerfil();
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error al cargar el perfil: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('No se pudo cargar el perfil.'));
            }

            final perfil = snapshot.data!;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              children: [
                // 1. Cabecera del Perfil
                PerfilHeaderCard(perfil: perfil),
                const SizedBox(height: 24),

                // 2. Nuevo Widget de Estatus (simplificado)
                InsigniaEstatusWidget(perfil: perfil),
                const SizedBox(height: 24),

                // 3. Agrupar Acciones Premium y de Actividad
                _buildSectionCard(
                  theme: theme,
                  title: 'Actividad y Beneficios',
                  children: [
                    
                    // --- CORRECCIÓN: Botón "Mi Actividad" CONDICIONAL ---
                    // Solo aparece si el usuario es 'lider_vecinal'
                    if (authNotifier.isLider)
                      PerfilActionTile(
                        icon: Icons.history_outlined, 
                        title: 'Mi Actividad Personal', // Texto más claro
                        subtitle: 'Ver mis reportes, apoyos y seguimientos', // Subtítulo
                        onTap: () => Navigator.pushNamed(context, '/mi_actividad'),
                      ),
                    
                    // --- NUEVO: Botón para Insignias ---
                    PerfilActionTile(
                      icon: Icons.emoji_events_outlined,
                      title: 'Mis Insignias y Progreso',
                      subtitle: 'Ver mis logros y próximos desafíos',
                      onTap: () => Navigator.pushNamed(context, '/insignias'),
                    ),
                    
                    // --- Acciones de Suscripción ---
                    if (authNotifier.isPremium)
                      PerfilActionTile(
                        icon: Icons.workspace_premium_outlined, 
                        title: 'Gestionar Suscripción', 
                        onTap: () => Navigator.pushNamed(context, '/gestionar_suscripcion'),
                        color: Colors.amber.shade700,
                      )
                    else
                      PerfilActionTile(
                        icon: Icons.workspace_premium_outlined, 
                        title: 'Ver Planes Premium', 
                        onTap: () => Navigator.pushNamed(context, '/subscription_plans'),
                        color: Colors.amber.shade700,
                      ),

                    // --- Acciones Premium (Premium o Reportero) ---
                    if (authNotifier.isPremium || authNotifier.userRole == 'reportero') ...[
                      if (authNotifier.userRole == 'reportero') ...[
                        PerfilActionTile( icon: Icons.analytics_outlined, title: 'Panel Analítico Global', onTap: () => Navigator.pushNamed(context, '/panel_analitico') ),
                        PerfilActionTile( icon: Icons.file_download_done_outlined, title: 'Mis Informes Guardados', onTap: () => Navigator.pushNamed(context, '/mis_informes') ),
                      ],
                      PerfilActionTile( icon: Icons.bar_chart_outlined, title: 'Mis Estadísticas', onTap: () => Navigator.pushNamed(context, '/estadisticas_personales') ),
                      PerfilActionTile( icon: Icons.notifications_active_outlined, title: 'Alertas Personalizadas', onTap: () => Navigator.pushNamed(context, '/alertas_personalizadas') ),
                    ],

                    // --- Postulación (Solo Ciudadano) ---
                    if (authNotifier.userRole == 'ciudadano') 
                      PerfilActionTile(
                        icon: Icons.how_to_reg_outlined, 
                        title: 'Postular como Líder Vecinal', 
                        onTap: _handlePostularLider,
                        color: theme.colorScheme.primary,
                      ),
                  ]
                ),
                
                const SizedBox(height: 24),

                // 4. Agrupar Acciones de Cuenta
                _buildSectionCard(
                  theme: theme,
                  title: 'Mi Cuenta',
                  children: [
                     PerfilActionTile( icon: Icons.credit_card_outlined, title: 'Historial de Pagos', onTap: () => Navigator.pushNamed(context, '/historial_pagos') ),
                     PerfilActionTile(icon: Icons.edit_outlined, title: 'Editar Perfil', onTap: () async {
                       final result = await Navigator.pushNamed(context, '/editar-perfil');
                       if (result == true && mounted) { _refreshProfile(); }
                     }),
                     PerfilActionTile(icon: Icons.settings_outlined, title: 'Configuración', onTap: () => Navigator.pushNamed(context, '/settings')),
                     PerfilActionTile(icon: Icons.logout, title: 'Cerrar Sesión', color: Colors.red, onTap: _handleLogout),
                  ]
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Helper para crear tarjetas de sección
  Widget _buildSectionCard({required ThemeData theme, required String title, required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Bordes más redondeados
        side: BorderSide(color: theme.dividerColor.withOpacity(0.5))
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // Padding ajustado
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 12.0, bottom: 4.0), // Ajuste de padding de título
              child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant)),
            ),
            // Los PerfilActionTile ya no tienen Card, así que están contenidos por esta
            ...children,
          ],
        ),
      ),
    );
  }
}