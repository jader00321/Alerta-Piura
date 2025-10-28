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

/// {@template perfil_screen}
/// Pantalla principal del perfil del usuario.
///
/// Muestra la información del usuario ([PerfilHeaderCard], [InsigniaEstatusWidget])
/// y proporciona acceso a varias secciones de gestión de cuenta y actividad
/// a través de [PerfilActionTile] agrupados en tarjetas.
/// Permite refrescar los datos y cerrar sesión.
/// {@endtemplate}
class PerfilScreen extends StatefulWidget {
  /// {@macro perfil_screen}
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

/// Estado para [PerfilScreen].
///
/// Maneja la carga inicial y el refresco de los datos del perfil.
/// Gestiona la acción de cerrar sesión y postular a líder.
class _PerfilScreenState extends State<PerfilScreen> {
  final PerfilService _perfilService = PerfilService();
  /// Futuro que contiene los datos del perfil del usuario.
  late Future<Perfil> _perfilFuture;

  @override
  void initState() {
    super.initState();
    _perfilFuture = _perfilService.getMiPerfil();
  }

  /// Refresca el estado de autenticación global y recarga los datos del perfil.
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

  /// Muestra un diálogo de confirmación y cierra la sesión del usuario.
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
              child: const Text('No'),
              onPressed: () => Navigator.pop(ctx, false)),
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
        // Navega a la raíz y elimina todo el historial
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    }
  }

  /// Muestra el diálogo [DialogoPostulacionLider] para que el usuario postule.
  /// Si la postulación es exitosa, refresca el perfil.
  Future<void> _handlePostularLider() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Evita cerrar tocando fuera
      builder: (ctx) => const DialogoPostulacionLider(),
    );
    if (result == true && mounted) {
      _refreshProfile(); // Refrescar para potencialmente mostrar estado de postulación
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
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: FutureBuilder<Perfil>(
          future: _perfilFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const EsqueletoPerfil();
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text('Error al cargar el perfil: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('No se pudo cargar el perfil.'));
            }

            final perfil = snapshot.data!;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(), // Permite el refresh
              padding: const EdgeInsets.all(16.0),
              children: [
                PerfilHeaderCard(perfil: perfil),
                const SizedBox(height: 24),
                InsigniaEstatusWidget(perfil: perfil),
                const SizedBox(height: 24),

                /// Sección de Actividad y Beneficios
                _buildSectionCard(
                    theme: theme,
                    title: 'Actividad y Beneficios',
                    children: [
                      if (authNotifier.isLider)
                        PerfilActionTile(
                          icon: Icons.history_outlined,
                          title: 'Mi Actividad Personal',
                          subtitle: 'Ver mis reportes, apoyos y seguimientos',
                          onTap: () =>
                              Navigator.pushNamed(context, '/mi_actividad'),
                        ),
                      PerfilActionTile(
                        icon: Icons.emoji_events_outlined,
                        title: 'Mis Insignias y Progreso',
                        subtitle: 'Ver mis logros y próximos desafíos',
                        onTap: () => Navigator.pushNamed(context, '/insignias'),
                      ),
                      if (authNotifier.isPremium)
                        PerfilActionTile(
                          icon: Icons.workspace_premium_outlined,
                          title: 'Gestionar Suscripción',
                          onTap: () async {
                            final refreshed = await Navigator.pushNamed(
                                context, '/gestionar_suscripcion');
                            if (refreshed == true && mounted) {
                              _refreshProfile();
                            }
                          },
                          color: Colors.amber.shade700,
                        )
                      else
                        PerfilActionTile(
                          icon: Icons.workspace_premium_outlined,
                          title: 'Ver Planes Premium',
                          onTap: () => Navigator.pushNamed(
                              context, '/subscription_plans'),
                          color: Colors.amber.shade700,
                        ),
                      if (authNotifier.isPremium ||
                          authNotifier.userRole == 'reportero') ...[
                        if (authNotifier.userRole == 'reportero') ...[
                          PerfilActionTile(
                              icon: Icons.analytics_outlined,
                              title: 'Panel Analítico Global',
                              onTap: () => Navigator.pushNamed(
                                  context, '/panel_analitico')),
                          PerfilActionTile(
                              icon: Icons.file_download_done_outlined,
                              title: 'Mis Informes Guardados',
                              onTap: () => Navigator.pushNamed(
                                  context, '/mis_informes')),
                        ],
                        PerfilActionTile(
                            icon: Icons.bar_chart_outlined,
                            title: 'Mis Estadísticas',
                            onTap: () => Navigator.pushNamed(
                                context, '/estadisticas_personales')),
                        PerfilActionTile(
                            icon: Icons.notifications_active_outlined,
                            title: 'Alertas Personalizadas',
                            onTap: () => Navigator.pushNamed(
                                context, '/alertas_personalizadas')),
                      ],
                      if (authNotifier.userRole == 'ciudadano')
                        PerfilActionTile(
                          icon: Icons.how_to_reg_outlined,
                          title: 'Postular como Líder Vecinal',
                          onTap: _handlePostularLider,
                          color: theme.colorScheme.primary,
                        ),
                    ]),
                const SizedBox(height: 24),

                /// Sección de Mi Cuenta
                _buildSectionCard(
                    theme: theme,
                    title: 'Mi Cuenta',
                    children: [
                      PerfilActionTile(
                          icon: Icons.credit_card_outlined,
                          title: 'Historial de Pagos',
                          onTap: () => Navigator.pushNamed(
                              context, '/historial_pagos')),
                      PerfilActionTile(
                          icon: Icons.edit_outlined,
                          title: 'Editar Perfil',
                          onTap: () async {
                            final result = await Navigator.pushNamed(
                                context, '/editar-perfil');
                            if (result == true && mounted) {
                              _refreshProfile();
                            }
                          }),
                      PerfilActionTile(
                          icon: Icons.settings_outlined,
                          title: 'Configuración',
                          onTap: () =>
                              Navigator.pushNamed(context, '/settings')),
                      PerfilActionTile(
                          icon: Icons.logout,
                          title: 'Cerrar Sesión',
                          color: Colors.red,
                          onTap: _handleLogout),
                    ]),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Helper para construir las tarjetas de sección con título y contenido.
  Widget _buildSectionCard(
      {required ThemeData theme,
      required String title,
      required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.dividerColor.withAlpha(128))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 12.0, top: 12.0, bottom: 4.0),
              child: Text(title,
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant)),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}