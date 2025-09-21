import 'package:flutter/material.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/screens/create_report_screen.dart';
import 'package:mobile_app/screens/home_screen.dart';
import 'package:mobile_app/screens/login_screen.dart';
import 'package:mobile_app/screens/mi_actividad_screen.dart';
import 'package:mobile_app/screens/notificaciones_screen.dart';
import 'package:mobile_app/screens/perfil_screen.dart';
import 'package:mobile_app/screens/register_screen.dart';
import 'package:mobile_app/screens/reporte_detalle_screen.dart';
import 'package:mobile_app/screens/settings_screen.dart';
import 'package:mobile_app/screens/splash_screen.dart';
import 'package:mobile_app/screens/verificacion_detalle_screen.dart';
import 'package:mobile_app/screens/verificacion_screen.dart';
import 'package:mobile_app/services/background_service.dart';
import 'package:mobile_app/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/theme_provider.dart';
import 'package:mobile_app/screens/editar_perfil_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await NotificationService().initialize();
  await initializeBackgroundService();
  
  runApp(
    // Use MultiProvider to provide both the Theme and Auth state
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthNotifier()),
      ],
      child: const AlertaPiuraApp(),
    ),
  );
}

class AlertaPiuraApp extends StatelessWidget {
  const AlertaPiuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        foregroundColor: Colors.white,
        backgroundColor: Colors.teal,
      ),
    );
    
    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'Alerta Piura',
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: lightTheme,
      darkTheme: darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/create_report': (context) => const CreateReportScreen(),
        '/perfil': (context) => const PerfilScreen(),
        '/mi_actividad': (context) => const MiActividadScreen(),
        '/verificacion': (context) => const VerificacionScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/notificaciones': (context) => const NotificacionesScreen(),
        '/editar-perfil': (context) => const EditarPerfilScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/reporte_detalle') {
          final args = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => ReporteDetalleScreen(reporteId: args),
          );
        }
        if (settings.name == '/verificacion_detalle') {
          final args = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => VerificacionDetalleScreen(reporteId: args),
          );
        }
        return null;
      },
    );
  }
}