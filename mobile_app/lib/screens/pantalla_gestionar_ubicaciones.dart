import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/map_preferences_provider.dart';
import 'package:mobile_app/models/ubicacion_guardada_model.dart';
import 'package:intl/intl.dart'; // Asegúrate de tener intl en pubspec (ya lo tienes)

/// {@template pantalla_gestionar_ubicaciones}
/// Pantalla avanzada para administrar las ubicaciones guardadas.
///
/// Permite:
/// 1. Ver la lista de ubicaciones guardadas.
/// 2. Seleccionar cuál será la ubicación de inicio por defecto.
/// 3. Restaurar la ubicación predeterminada del sistema.
/// 4. Eliminar ubicaciones guardadas.
/// {@endtemplate}
class PantallaGestionarUbicaciones extends StatelessWidget {
  const PantallaGestionarUbicaciones({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos watch para que la pantalla se reconstruya al cambiar las preferencias
    final mapProvider = context.watch<MapPreferencesProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicaciones Guardadas'),
      ),
      body: mapProvider.ubicaciones.isEmpty
          ? _buildEmptyView(context)
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSystemDefaultOption(context, mapProvider),
                const SizedBox(height: 24),
                Text(
                  'Mis Ubicaciones (${mapProvider.ubicaciones.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...mapProvider.ubicaciones.map((ubicacion) {
                  return _buildLocationItem(context, mapProvider, ubicacion);
                }).toList(),
              ],
            ),
    );
  }

  /// Vista cuando no hay ubicaciones guardadas.
  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No tienes ubicaciones guardadas.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ve al mapa y pulsa el botón "Casa"\npara guardar tu vista actual.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Tarjeta para la opción "Predeterminado del Sistema".
  Widget _buildSystemDefaultOption(
      BuildContext context, MapPreferencesProvider provider) {
    final isSystemDefault = provider.defaultLocationId == null;

    return Card(
      elevation: isSystemDefault ? 4 : 1,
      color: isSystemDefault
          ? Theme.of(context).colorScheme.primaryContainer.withAlpha(100)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSystemDefault
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: RadioListTile<String?>(
        value: null, // null representa el sistema
        groupValue: provider.defaultLocationId,
        onChanged: (value) => provider.restoreSystemDefault(),
        title: const Text(
          'Ubicación del Sistema (Piura Centro)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Usar la configuración por defecto de la app.'),
        secondary: const Icon(Icons.settings_system_daydream),
      ),
    );
  }

  /// Tarjeta para cada ubicación guardada.
  Widget _buildLocationItem(BuildContext context, MapPreferencesProvider provider,
      UbicacionGuardada ubicacion) {
    // ignore: unused_local_variable
    final isSelected = provider.defaultLocationId == ubicacion.id;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Dismissible(
      key: Key(ubicacion.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Eliminar ubicación'),
            content: Text('¿Borrar "${ubicacion.nombre}" de tus guardados?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        provider.removeLocation(ubicacion.id);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${ubicacion.nombre} eliminada')));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: RadioListTile<String?>(
          value: ubicacion.id,
          groupValue: provider.defaultLocationId,
          onChanged: (value) => provider.setDefaultLocation(ubicacion.id),
          title: Text(ubicacion.nombre,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(
            'Lat: ${ubicacion.lat.toStringAsFixed(4)}, Lng: ${ubicacion.lng.toStringAsFixed(4)}\nGuardado: ${dateFormat.format(ubicacion.fechaCreacion)}',
            style: const TextStyle(fontSize: 12),
          ),
          secondary: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.grey),
            onPressed: () {
              // Confirmación manual si no usan el swipe
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Eliminar ubicación'),
                  content:
                      Text('¿Borrar "${ubicacion.nombre}" de tus guardados?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancelar')),
                    TextButton(
                        onPressed: () {
                          provider.removeLocation(ubicacion.id);
                          Navigator.pop(ctx);
                        },
                        child: const Text('Eliminar',
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}