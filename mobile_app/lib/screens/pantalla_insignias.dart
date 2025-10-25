// lib/screens/pantalla_insignias.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/api/gamificacion_service.dart';
import 'package:mobile_app/models/insignia_detalle_model.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_lista_actividad.dart'; // Reutilizamos un esqueleto

class PantallaInsignias extends StatefulWidget {
  const PantallaInsignias({super.key});

  @override
  State<PantallaInsignias> createState() => _PantallaInsigniasState();
}

class _PantallaInsigniasState extends State<PantallaInsignias> {
  final GamificacionService _gamificacionService = GamificacionService();
  late Future<ProgresoInsignias> _progresoFuture;

  @override
  void initState() {
    super.initState();
    _progresoFuture = _gamificacionService.getProgresoInsignias();
  }

  // Función para obtener el icono basado en el 'icono_url'
  IconData _obtenerIcono(String? iconoUrl) {
    switch (iconoUrl) {
      case 'premium_shield': return Icons.shield_rounded;
      case 'reporter_badge': return Icons.assignment_ind_rounded;
      case 'collaborator_star': return Icons.star_purple500_rounded;
      case 'city_defender_crest': return Icons.verified_user_rounded;
      case 'school': return Icons.school_rounded; // Ciudadano Iniciado
      case 'record_voice_over': return Icons.record_voice_over_rounded; // Voz Activa
      case 'security': return Icons.security_rounded; // Guardián del Barrio
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
            return Center(child: Text('Error al cargar insignias: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No se encontró información de insignias.'));
          }

          final progreso = snapshot.data!;
          final puntosUsuario = progreso.puntosUsuario;

          // Separar insignias en ganadas y por desbloquear (solo de progreso)
          final insigniasGanadas = progreso.insignias
              .where((i) => i.isEarned && (i.puntosNecesarios ?? 0) > 0)
              .toList();
          final insigniasBloqueadas = progreso.insignias
              .where((i) => !i.isEarned && (i.puntosNecesarios ?? 0) > 0)
              .toList();
              
          // Encontrar la próxima insignia
          InsigniaDetalle? proximaInsignia;
          if(insigniasBloqueadas.isNotEmpty) {
            proximaInsignia = insigniasBloqueadas.first;
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // --- Tarjeta de Puntos y Próxima Insignia ---
              Card(
                elevation: 4,
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text('Tus Puntos de Comunidad', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                      Text(
                        puntosUsuario.toString(),
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        proximaInsignia != null ? 'Siguiente Desafío:' : '¡Has desbloqueado todo!',
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        proximaInsignia != null 
                          ? '${proximaInsignia.nombre} (${proximaInsignia.puntosNecesarios} Puntos)'
                          : 'Sigue participando',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (proximaInsignia != null) ...[
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: (puntosUsuario / (proximaInsignia.puntosNecesarios ?? 1)),
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(proximaInsignia.puntosNecesarios! - puntosUsuario)} puntos restantes',
                          style: theme.textTheme.bodySmall,
                        ),
                      ]
                    ],
                  ),
                ),
              ),

              // --- Insignias Obtenidas ---
              Padding(
                padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
                child: Text('Insignias Obtenidas (${insigniasGanadas.length})', style: theme.textTheme.headlineSmall),
              ),
              if (insigniasGanadas.isEmpty)
                const Text('¡Sigue reportando y comentando para ganar tu primera insignia!')
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
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

              // --- Insignias por Desbloquear ---
              Padding(
                padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
                child: Text('Por Desbloquear (${insigniasBloqueadas.length})', style: theme.textTheme.headlineSmall),
              ),
              if (insigniasBloqueadas.isEmpty)
                const Text('¡Felicidades! Has conseguido todas las insignias de progreso.')
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
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
            ],
          );
        },
      ),
    );
  }
}

// Widget interno para mostrar cada insignia en la cuadrícula
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
        ? "${insignia.descripcion}\nRequiere: ${insignia.puntosNecesarios} puntos"
        : insignia.descripcion,
      child: Card(
        elevation: isLocked ? 0 : 2,
        color: isLocked ? theme.colorScheme.surfaceVariant.withOpacity(0.3) : theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isLocked ? Icons.lock_outline : icono,
                size: 40,
                color: isLocked ? Colors.grey.shade500 : color,
              ),
              const SizedBox(height: 12),
              Text(
                insignia.nombre,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isLocked ? Colors.grey.shade600 : null,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (isLocked) ...[
                const SizedBox(height: 4),
                Text(
                  '${insignia.puntosNecesarios} Pts',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}