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
      default: return Icons.emoji_events_outlined; // Icono por defecto
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
            return const EsqueletoListaActividad(); // Muestra esqueleto mientras carga
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar insignias: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No se encontró información de insignias.'));
          }

          final progreso = snapshot.data!;
          final puntosUsuario = progreso.puntosUsuario;

          // Separar insignias
          final insigniasGanadas = progreso.insignias
              .where((i) => i.isEarned && (i.puntosNecesarios ?? 0) > 0)
              .toList();
          final insigniasBloqueadas = progreso.insignias
              .where((i) => !i.isEarned && (i.puntosNecesarios ?? 0) > 0)
              .toList();

          // Encontrar la próxima insignia por puntos
          InsigniaDetalle? proximaInsignia;
          // Ordenar bloqueadas por puntos necesarios ascendente para encontrar la próxima
          insigniasBloqueadas.sort((a, b) => (a.puntosNecesarios ?? 0).compareTo(b.puntosNecesarios ?? 0));
          if(insigniasBloqueadas.isNotEmpty) {
            proximaInsignia = insigniasBloqueadas.firstWhere((i) => (i.puntosNecesarios ?? 0) > puntosUsuario, orElse: () => insigniasBloqueadas.last);
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
                        style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer), // Ajustar color
                      ),
                      Text(
                        proximaInsignia != null
                          ? '${proximaInsignia.nombre} (${proximaInsignia.puntosNecesarios} Puntos)'
                          : 'Sigue participando',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                           color: theme.colorScheme.onPrimaryContainer, // Ajustar color
                           fontSize: 20 // Ajustar tamaño si es muy grande
                        ),
                         textAlign: TextAlign.center, // Centrar texto
                      ),
                      if (proximaInsignia != null && proximaInsignia.puntosNecesarios != null && proximaInsignia.puntosNecesarios! > 0) ...[ // Chequeo adicional
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          // Asegurar que el valor esté entre 0 y 1
                          value: (puntosUsuario / proximaInsignia.puntosNecesarios!).clamp(0.0, 1.0),
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(5),
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.2), // Fondo más claro
                          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary), // Color primario
                        ),
                        const SizedBox(height: 4),
                        Text(
                          // Calcular puntos restantes asegurando que no sea negativo
                          '${(proximaInsignia.puntosNecesarios! - puntosUsuario).clamp(0, proximaInsignia.puntosNecesarios!)} puntos restantes',
                           style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimaryContainer), // Ajustar color
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
                const Padding( // Añadir padding
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('¡Sigue participando para ganar tu primera insignia!'),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Número de columnas
                    crossAxisSpacing: 12, // Espacio horizontal
                    mainAxisSpacing: 12, // Espacio vertical
                    childAspectRatio: 0.85, // Relación ancho/alto (ajustar si es necesario)
                  ),
                  itemCount: insigniasGanadas.length,
                  itemBuilder: (context, index) {
                    final insignia = insigniasGanadas[index];
                    return _InsigniaCard(
                      insignia: insignia,
                      icono: _obtenerIcono(insignia.iconoUrl),
                      color: theme.colorScheme.primary, // Color para insignias ganadas
                      isLocked: false,
                    );
                  },
                ),

              // --- Insignias por Desbloquear ---
              Padding(
                padding: const EdgeInsets.only(top: 32.0, bottom: 12.0),
                child: Text('Por Desbloquear (${insigniasBloqueadas.length})', style: theme.textTheme.headlineSmall),
              ),
              if (insigniasBloqueadas.isEmpty)
                 const Padding( // Añadir padding
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('¡Felicidades! Has conseguido todas las insignias de progreso.'),
                 )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85, // Misma relación de aspecto
                  ),
                  itemCount: insigniasBloqueadas.length,
                  itemBuilder: (context, index) {
                    final insignia = insigniasBloqueadas[index];
                    return _InsigniaCard(
                      insignia: insignia,
                      icono: _obtenerIcono(insignia.iconoUrl),
                      color: Colors.grey.shade600, // Color para insignias bloqueadas
                      isLocked: true,
                    );
                  },
                ),
                 const SizedBox(height: 18), // Espacio extra al final
            ],
          );
        },
      ),
    );
  }
}

// --- Widget _InsigniaCard CORREGIDO ---
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
        ? "${insignia.descripcion}\nRequiere: ${insignia.puntosNecesarios ?? '?'} puntos" // Mensaje para bloqueadas
        : insignia.descripcion, // Mensaje para desbloqueadas
      preferBelow: false, // Mostrar tooltip arriba si es posible
      child: Card(
        elevation: isLocked ? 0 : 2, // Sin elevación si está bloqueada
        // Color de fondo diferente si está bloqueada
        color: isLocked ? theme.colorScheme.onSurface.withOpacity(0.05) : theme.cardColor,
        clipBehavior: Clip.antiAlias, // Para asegurar bordes redondeados
        child: Padding(
          padding: const EdgeInsets.all(5.0), // Reducir padding si es necesario
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isLocked ? Icons.lock_outline : icono, // Icono de candado o el de la insignia
                size: 36, // Tamaño del icono
                color: isLocked ? Colors.grey.shade500 : color, // Color diferente si está bloqueada
              ),
              const SizedBox(height: 8), // Espacio
              Text(
                insignia.nombre,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isLocked ? Colors.grey.shade600 : null, // Color de texto diferente
                ),
                textAlign: TextAlign.center,
                // --- CORRECCIONES ---
                maxLines: 2, // Permitir hasta 2 líneas
                overflow: TextOverflow.ellipsis, // Usar ellipsis si excede 2 líneas
                softWrap: true, // Permitir el salto de línea
                // --- FIN CORRECCIONES ---
              ),
              if (isLocked && insignia.puntosNecesarios != null) ...[ // Mostrar puntos solo si está bloqueada y tiene puntos definidos
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
// --- FIN Widget _InsigniaCard CORREGIDO ---