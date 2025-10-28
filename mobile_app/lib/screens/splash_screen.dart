import 'package:flutter/material.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// {@template splash_screen}
/// Pantalla de carga inicial (Splash) de la aplicación.
///
/// Se muestra al iniciar la app mientras se realizan las verificaciones
/// iniciales de autenticación antes de navegar a la pantalla principal.
/// {@endtemplate}
class SplashScreen extends StatefulWidget {
  /// {@macro splash_screen}
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// Estado para [SplashScreen].
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Realiza la inicialización de la app.
  ///
  /// Espera 2 segundos, verifica el estado del token de autenticación
  /// (y lo refresca si existe usando [AuthNotifier.refreshUserStatus])
  /// y luego navega a la pantalla principal (`/home`).
  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);

    // Si había un token, refresca el estado del usuario desde el backend
    if (authNotifier.isAuthenticated) {
      await authNotifier.refreshUserStatus();
    }

    // Navega a home independientemente del estado (HomeScreen manejará la redirección)
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_moon_outlined, size: 80, color: Colors.teal),
            SizedBox(height: 20),
            Text(
              'Reporta Piura',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Tu voz, por fin escuchada.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}