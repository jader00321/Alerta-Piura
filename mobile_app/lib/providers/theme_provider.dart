import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestiona el tema (claro/oscuro) de la aplicación.
///
/// Utiliza [ChangeNotifier] para notificar a los widgets cuando el tema cambia.
/// Almacena la preferencia del usuario de forma persistente
/// usando [SharedPreferences].
class ThemeProvider with ChangeNotifier {
  /// El estado actual del tema. `true` para modo oscuro, `false` para modo claro.
  bool _isDarkMode = false;

  /// Retorna `true` si el modo oscuro está activo.
  bool get isDarkMode => _isDarkMode;

  /// Carga la preferencia de tema guardada por el usuario.
  ///
  /// Busca 'isDarkMode' en [SharedPreferences]. Si no se encuentra,
  /// usa `false` (modo claro) como valor por defecto.
  /// Notifica a los oyentes después de cargar el tema.
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  /// Establece el modo del tema (claro u oscuro).
  ///
  /// Actualiza el estado, guarda la preferencia [isDarkMode] en [SharedPreferences],
  /// y notifica a los oyentes para que la UI se reconstruya con el nuevo tema.
  Future<void> setThemeMode(bool isDarkMode) async {
    _isDarkMode = isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }
}