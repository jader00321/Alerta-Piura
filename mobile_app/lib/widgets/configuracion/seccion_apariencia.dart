import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/theme_provider.dart';

class SeccionApariencia extends StatelessWidget {
  const SeccionApariencia({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();

    return Card(
      elevation: 2,
      child: Consumer<ThemeProvider>(
        builder: (context, provider, child) {
          return SwitchListTile(
            title: const Text('Modo Oscuro'),
            subtitle: const Text('Activa o desactiva el tema oscuro.'),
            value: provider.isDarkMode,
            onChanged: (value) {
              themeProvider.setThemeMode(value);
            },
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
