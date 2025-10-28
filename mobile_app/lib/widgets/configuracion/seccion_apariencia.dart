import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/theme_provider.dart';

/// {@template seccion_apariencia}
/// Un widget reutilizable que muestra la sección de "Apariencia"
/// dentro de la pantalla de [SettingsScreen].
///
/// Permite al usuario cambiar el tema de la aplicación (Modo Claro / Modo Oscuro)
/// a través de un [SwitchListTile].
///
/// Este widget utiliza [Consumer] de `provider` para escuchar y reaccionar
/// a los cambios en [ThemeProvider], y [context.read] para llamar al
/// método [ThemeProvider.setThemeMode] y persistir el cambio.
/// {@endtemplate}
class SeccionApariencia extends StatelessWidget {
  /// {@macro seccion_apariencia}
  const SeccionApariencia({super.key});

  @override
  Widget build(BuildContext context) {
    /// Obtiene la instancia del [ThemeProvider] usando `context.read`.
    /// Se usa `read` aquí porque solo necesitamos llamar al *método* [setThemeMode],
    /// no necesitamos que este widget `build` se reconstruya cuando el tema cambie
    /// (de eso se encarga el [Consumer] más abajo).
    final themeProvider = context.read<ThemeProvider>();

    return Card(
      elevation: 2,
      child:
          /// [Consumer] escucha específicamente los cambios en [ThemeProvider].
          /// Solo este [SwitchListTile] se reconstruirá cuando [provider.isDarkMode]
          /// cambie, optimizando el rendimiento de [SettingsScreen].
          Consumer<ThemeProvider>(
        builder: (context, provider, child) {
          return SwitchListTile(
            title: const Text('Modo Oscuro'),
            subtitle: const Text('Activa o desactiva el tema oscuro.'),
            /// El valor del switch se obtiene del estado actual del provider.
            value: provider.isDarkMode,
            /// Al cambiar el valor, llama al método [setThemeMode] del provider
            /// para actualizar el tema en toda la aplicación y guardarlo
            /// en [SharedPreferences].
            onChanged: (value) {
              themeProvider.setThemeMode(value);
            },
            /// El icono cambia dinámicamente para reflejar el estado actual.
            secondary: Icon(
              provider.isDarkMode
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
            ),
          );
        },
      ),
    );
  }
}