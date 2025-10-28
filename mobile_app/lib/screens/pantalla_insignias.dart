import 'package:flutter/material.dart';
import 'package:mobile_app/api/gamificacion_service.dart';
import 'package:mobile_app/models/insignia_detalle_model.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_lista_actividad.dart';

/// {@template pantalla_insignias}
/// Pantalla que muestra el progreso del usuario en el sistema de gamificación.
///
/// Muestra los puntos actuales del usuario, la próxima insignia a desbloquear,
/// y una galería de todas las insignias disponibles (ganadas y bloqueadas).
/// {@endtemplate}
class PantallaInsignias extends StatefulWidget {
  /// {@macro pantalla_insignias}
  const PantallaInsignias({super.key});

  @override
  State<PantallaInsignias> createState() => _PantallaInsigniasState();
}

/// Estado para [PantallaInsignias].
///
/// Maneja la carga del progreso de insignias desde [GamificacionService].
class _PantallaInsigniasState extends State<PantallaInsignias> {
  final GamificacionService _gamificacionService = GamificacionService();
  
  /// Futuro que contiene el [ProgresoInsignias] del usuario.
  late Future<ProgresoInsignias> _progresoFuture;

  @override
  void initState() {
    super.initState();
    _progresoFuture = _gamificacionService.getProgresoInsignias();
  }

  /// Mapea el nombre del icono (string) a un [IconData].
  IconData _obtenerIcono(String? iconoUrl) {
    switch (iconoUrl) {
      case 'premium_shield': return Icons.shield_rounded;
      case 'reporter_badge': return Icons.assignment_ind_rounded;
      case 'collaborator_star': return Icons.star_purple500_rounded;
      case 'city_defender_crest': return Icons.verified_user_rounded;
      case 'school': return Icons.school_rounded;
      case 'record_voice_over': return Icons.record_voice_over_rounded;
      case 'security': return Icons.security_rounded;
      default: return Icons.emoji_events_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Insignias y Progreso'),
      ),
      body: FutureBuilder<ProgresoInsignias>(
        future: _progresoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const EsqueletoListaActividad();
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error al cargar insignias: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(
                child: Text('No se encontró información de insignias.'));
          }

          final progreso = snapshot.data!;
          final puntosUsuario = progreso.puntosUsuario;

          final insigniasGanadas = progreso.insignias
              .where((i) => i.isEarned && (i.puntosNecesarios ?? 0) > 0)
              .toList();
          final insigniasBloqueadas = progreso.insignias
              .where((i) => !i.isEarned && (i.puntosNecesarios ?? 0) > 0)
              .toList();

          InsigniaDetalle? proximaInsignia;
          // Ordenar bloqueadas por puntos necesarios para encontrar la próxima
          insigniasBloqueadas.sort(
              (a, b) => (a.puntosNecesarios ?? 0).compareTo(b.puntosNecesarios ?? 0));
          if (insigniasBloqueadas.isNotEmpty) {
            proximaInsignia = insigniasBloqueadas.firstWhere(
                (i) => (i.puntosNecesarios ?? 0) > puntosUsuario,
                orElse: () => insigniasBloqueadas.last);
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                elevation: 4,
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text('Tus Puntos de Comunidad',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                      Text(
                        puntosUsuario.toString(),
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        proximaInsignia != null
                            ? 'Siguiente Desafío:'
                            : '¡Has desbloqueado todo!',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                      ),
                      Text(
                        proximaInsignia != null
                            ? '${proximaInsignia.nombre} (${proximaInsignia.puntosNecesarios} Puntos)'
                            : 'Sigue participando',
                        style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                            fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      if (proximaInsignia != null &&
                          proximaInsignia.puntosNecesarios != null &&
                          proximaInsignia.puntosNecesarios! > 0) ...[
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: (puntosUsuario / proximaInsignia.puntosNecesarios!)
                              .clamp(0.0, 1.0),
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(5),
                          backgroundColor: theme.colorScheme.primary.withAlpha(51),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(proximaInsignia.puntosNecesarios! - puntosUsuario).clamp(0, proximaInsignia.puntosNecesarios!)} puntos restantes',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
                child: Text('Insignias Obtenidas (${insigniasGanadas.length})',
                    style: theme.textTheme.headlineSmall),
              ),
              if (insigniasGanadas.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('¡Sigue participando para ganar tu primera insignia!'),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: insigniasGanadas.length,
                  itemBuilder: (context, index) {
                    final insignia = insigniasGanadas[index];
                    return _InsigniaCard(
                      insignia: insignia,
                      icono: _obtenerIcono(insignia.iconoUrl),
                      color: theme.colorScheme.primary,
                      isLocked: false,
                    );
                  },
                ),
              Padding(
                padding: const EdgeInsets.only(top: 32.0, bottom: 12.0),
                child: Text('Por Desbloquear (${insigniasBloqueadas.length})',
                    style: theme.textTheme.headlineSmall),
              ),
              if (insigniasBloqueadas.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                      '¡Felicidades! Has conseguido todas las insignias de progreso.'),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: insigniasBloqueadas.length,
                  itemBuilder: (context, index) {
                    final insignia = insigniasBloqueadas[index];
                    return _InsigniaCard(
                      insignia: insignia,
                      icono: _obtenerIcono(insignia.iconoUrl),
                      color: Colors.grey.shade600,
                      isLocked: true,
                    );
                  },
                ),
              const SizedBox(height: 18),
            ],
          );
        },
      ),
    );
  }
}

/// Widget interno para mostrar una tarjeta de insignia (ganada o bloqueada).
class _InsigniaCard extends StatelessWidget {
  final InsigniaDetalle insignia;
  final IconData icono;
  final Color color;
  final bool isLocked;

  const _InsigniaCard({
    required this.insignia,
    required this.icono,
    required this.color,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: isLocked
          ? "${insignia.descripcion}\nRequiere: ${insignia.puntosNecesarios ?? '?'} puntos"
          : insignia.descripcion,
      preferBelow: false,
      child: Card(
        elevation: isLocked ? 0 : 2,
        color: isLocked ? theme.colorScheme.onSurface.withAlpha(13) : theme.cardColor,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isLocked ? Icons.lock_outline : icono,
                size: 36,
                color: isLocked ? Colors.grey.shade500 : color,
              ),
              const SizedBox(height: 8),
              Text(
                insignia.nombre,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isLocked ? Colors.grey.shade600 : null,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
              if (isLocked && insignia.puntosNecesarios != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${insignia.puntosNecesarios} Pts',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey.shade600),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}