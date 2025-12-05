import 'package:flutter/material.dart';
import 'package:mobile_app/api/perfil_service.dart';
import 'package:mobile_app/models/perfil_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_perfil.dart';
import 'package:mobile_app/widgets/perfil/perfil_header_card.dart';
import 'package:mobile_app/widgets/perfil/perfil_action_tile.dart';
import 'package:mobile_app/widgets/perfil/dialogo_postulacion_lider.dart';
import 'package:provider/provider.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  // Quitamos 'late' y lo hacemos nullable (?) o lo inicializamos en initState sin await
  late Future<Perfil> _perfilFuture;
  final PerfilService _perfilService = PerfilService();
  
  bool _tieneSolicitudPendiente = false;

  @override
  void initState() {
    super.initState();
    // 1. INICIALIZACIÓN INMEDIATA (Sin await)
    // Esto evita el error de "LateInitializationError" porque la variable
    // tiene valor antes de que se ejecute el primer build().
    _perfilFuture = _perfilService.getMiPerfil();

    // 2. Actualización de Rol en segundo plano
    // Lo hacemos después de que el widget se monte para no bloquear la UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUserRole();
    });
  }

  /// Refresca el rol global en el AuthNotifier sin bloquear la vista
  Future<void> _refreshUserRole() async {
    if (!mounted) return;
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    await authNotifier.refreshUserStatus();
  }

  /// Función para el "Pull to Refresh" manual
  Future<void> _handleRefresh() async {
    await _refreshUserRole(); // Actualizamos rol
    setState(() {
      _perfilFuture = _perfilService.getMiPerfil(); // Recargamos perfil
    });
    await _perfilFuture; // Esperamos para que el RefreshIndicator sepa cuándo terminar
  }

  Future<void> _handleLogout() async {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    await authNotifier.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _abrirDialogoPostulacion() async {
    if (_tieneSolicitudPendiente) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ya tienes una solicitud en revisión.'))
      );
      return;
    }

    final result = await showDialog(
      context: context,
      builder: (context) => const DialogoPostulacionLider(),
    );
    
    if (result == true && mounted) {
      setState(() {
        _tieneSolicitudPendiente = true;
      });
      _handleRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();
    final theme = Theme.of(context);
    final isLider = authNotifier.isLider;
    final isReportero = authNotifier.userRole == 'reportero';
    final isAdmin = authNotifier.userRole == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: FutureBuilder<Perfil>(
          future: _perfilFuture,
          builder: (context, snapshot) {
            // 1. Cargando
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const EsqueletoPerfil();
            }
            // 2. Error
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Error al cargar perfil'),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: _handleRefresh, child: const Text('Reintentar'))
                  ],
                ),
              );
            }

            // 3. Datos Listos
            if (!snapshot.hasData) {
               return const Center(child: Text("No se encontraron datos."));
            }

            final perfil = snapshot.data!;
            final bool hasActivePlan = perfil.nombrePlan != null;

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // --- 1. CABECERA DINÁMICA ---
                PerfilHeaderCard(perfil: perfil),
                
                const SizedBox(height: 24),

                // --- 2. SECCIÓN MEMBRESÍA ---
                _buildSectionCard(
                  theme: theme,
                  title: "MI MEMBRESÍA",
                  children: [
                    PerfilActionTile(
                      icon: Icons.workspace_premium_outlined,
                      title: hasActivePlan ? 'Gestionar Suscripción' : 'Obtener Premium',
                      subtitle: hasActivePlan ? perfil.nombrePlan : 'Desbloquea funciones SOS',
                      color: hasActivePlan ? Colors.amber.shade800 : null,
                      onTap: () => Navigator.pushNamed(context, 
                          hasActivePlan ? '/gestionar_suscripcion' : '/subscription_plans'),
                    ),
                    PerfilActionTile(
                      icon: Icons.emoji_events_outlined,
                      title: 'Mis Insignias y Logros',
                      subtitle: 'Ver mi progreso gamificado',
                      onTap: () => Navigator.pushNamed(context, '/insignias'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),

                // --- 3. SECCIÓN COMUNIDAD ---
                _buildSectionCard(
                  theme: theme,
                  title: "COMUNIDAD",
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
                      icon: Icons.chat_bubble_outline,
                      title: 'Mis Conversaciones',
                      subtitle: 'Chats activos con líderes o administradores.',
                      onTap: () => Navigator.pushNamed(context, '/conversaciones'),
                    ),    
                    if (isReportero || isAdmin)
                      PerfilActionTile(
                        icon: Icons.analytics_outlined,
                        title: 'Panel de Prensa',
                        subtitle: 'Estadísticas globales de la ciudad',
                        color: Colors.deepOrange,
                        onTap: () => Navigator.pushNamed(context, '/panel_analitico'),
                      ),
                    
                    if (!isLider && !isReportero && !isAdmin)
                      PerfilActionTile(
                        icon: _tieneSolicitudPendiente ? Icons.timelapse : Icons.volunteer_activism,
                        title: _tieneSolicitudPendiente ? 'Solicitud Enviada' : 'Postular como Líder',
                        subtitle: _tieneSolicitudPendiente 
                            ? 'Tu postulación está en revisión' 
                            : 'Ayuda a verificar reportes en tu zona',
                        color: _tieneSolicitudPendiente ? Colors.grey : null,
                        onTap: _abrirDialogoPostulacion,
                      ),
                      
                    if (hasActivePlan || isLider || isReportero || isAdmin)
                      PerfilActionTile(
                        icon: Icons.bar_chart_rounded,
                        title: 'Mis Estadísticas',
                        subtitle: 'Análisis de tu actividad',
                        onTap: () => Navigator.pushNamed(context, '/estadisticas_personales'),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // --- 4. SECCIÓN FINANZAS ---
                if (hasActivePlan || isAdmin) 
                   _buildSectionCard(
                    theme: theme,
                    title: "FINANZAS",
                    children: [
                      PerfilActionTile(
                        icon: Icons.receipt_long_outlined,
                        title: 'Historial de Pagos',
                        onTap: () => Navigator.pushNamed(context, '/historial_pagos'),
                      ),
                      PerfilActionTile(
                        icon: Icons.credit_card_outlined,
                        title: 'Métodos de Pago',
                        onTap: () => Navigator.pushNamed(context, '/metodos_pago'),
                      ),
                    ],
                  ),

                const SizedBox(height: 16),

                // --- 5. CONFIGURACIÓN ---
                _buildSectionCard(
                  theme: theme,
                  title: "CONFIGURACIÓN",
                  children: [
                    PerfilActionTile(
                      icon: Icons.settings_outlined,
                      title: 'Preferencias',
                      onTap: () => Navigator.pushNamed(context, '/settings'),
                    ),
                    PerfilActionTile(
                      icon: Icons.edit_outlined,
                      title: 'Editar Datos Personales',
                      onTap: () async {
                        final result = await Navigator.pushNamed(context, '/editar-perfil');
                        if (result == true) _handleRefresh();
                      },
                    ),
                    const Divider(),
                    PerfilActionTile(
                      icon: Icons.logout,
                      title: 'Cerrar Sesión',
                      color: Colors.red.shade700,
                      onTap: _handleLogout,
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required ThemeData theme,
    required String title,
    required List<Widget> children,
  }) {
    if (children.isEmpty) return const SizedBox.shrink();
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.secondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Card(
          elevation: 0,
          // Usamos surfaceContainerLowest para un fondo sutil pero distinto
          color: isDark 
              ? theme.colorScheme.surfaceContainer // Un gris más visible y claro
              : theme.colorScheme.surface,         // Blanco en modo claro
          
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            // El borde lo hacemos un poco más visible también
            side: BorderSide(
              color: theme.dividerColor.withOpacity(isDark ? 0.3 : 0.5),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }
}