import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/theme_provider.dart';

class SeccionApariencia extends StatelessWidget {
  const SeccionApariencia({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos context.read aquí porque solo necesitamos llamar a la función,
    // no necesitamos que este widget se reconstruya cuando el tema cambie.
    final themeProvider = context.read<ThemeProvider>();
    
    // Usamos un Consumer para que solo el Switch se reconstruya al cambiar de tema.
    return Card(
      elevation: 2,
      child: Consumer<ThemeProvider>(
        builder: (context, provider, child) {
          return SwitchListTile(
            title: const Text('Modo Oscuro'),
            subtitle: const Text('Activa o desactiva el tema oscuro.'),
            value: provider.isDarkMode,
            onChanged: (value) {
              // Usamos el nuevo método con un nombre más claro
              themeProvider.setThemeMode(value);
            },
            secondary: Icon(
              provider.isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            ),
          );
        },
      ),
    );
  }
}