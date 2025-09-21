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
    // Check the session status
    await Provider.of<AuthNotifier>(context, listen: false).checkAuthStatus();
    // After checking, always navigate to the home screen
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
            Text('Alerta Piura', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}