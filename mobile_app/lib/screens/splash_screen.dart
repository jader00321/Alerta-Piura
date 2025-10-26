import 'package:flutter/material.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Espera un momento para que la pantalla de bienvenida sea visible.
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      final authNotifier = Provider.of<AuthNotifier>(context, listen: false);

      // --- CAMBIO CLAVE ---
      // En lugar de solo leer el token guardado, forzamos una
      // verificación con el servidor para obtener el estado más reciente.
      if (authNotifier.isAuthenticated) {
        await authNotifier.refreshUserStatus();
      }
    }

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
