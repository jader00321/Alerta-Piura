import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/providers/theme_provider.dart';
import 'package:mobile_app/services/background_service.dart';
import 'package:mobile_app/services/notification_service.dart';
import 'package:mobile_app/services/socket_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'package:mobile_app/screens/splash_screen.dart';
import 'package:mobile_app/screens/home_screen.dart';
import 'package:mobile_app/screens/login_screen.dart';
import 'package:mobile_app/screens/register_screen.dart';
import 'package:mobile_app/screens/perfil_screen.dart';
import 'package:mobile_app/screens/editar_perfil_screen.dart';
import 'package:mobile_app/screens/settings_screen.dart';
import 'package:mobile_app/screens/editar_contacto_screen.dart';
import 'package:mobile_app/screens/mi_actividad_screen.dart';
import 'package:mobile_app/screens/create_report_screen.dart';
import 'package:mobile_app/screens/reporte_detalle_screen.dart';
import 'package:mobile_app/screens/pantalla_cerca_de_ti.dart';
import 'package:mobile_app/screens/verificacion_detalle_screen.dart';
import 'package:mobile_app/screens/chat_screen.dart';
import 'package:mobile_app/screens/conversaciones_screen.dart';
import 'package:mobile_app/screens/pantalla_alertas.dart';
import 'package:mobile_app/screens/pantalla_planes_suscripcion.dart';
import 'package:mobile_app/screens/pantalla_historial_pagos.dart';
import 'package:mobile_app/screens/pantalla_detalle_boleta.dart';
import 'package:mobile_app/screens/pantalla_estadisticas_personales.dart';
import 'package:mobile_app/screens/pantalla_alertas_personalizadas.dart';
import 'package:mobile_app/screens/pantalla_crear_zona.dart';
import 'package:mobile_app/screens/pantalla_gestionar_suscripcion.dart';
import 'package:mobile_app/screens/pantalla_metodos_pago.dart';
import 'package:mobile_app/screens/pantalla_agregar_metodo_pago.dart';
import 'package:mobile_app/screens/pantalla_panel_analitico.dart';
import 'package:mobile_app/screens/pantalla_informes_guardados.dart';
import 'package:mobile_app/screens/pantalla_detalle_pendiente_vista.dart';
import 'package:mobile_app/models/plan_suscripcion_model.dart';
import 'package:mobile_app/screens/pantalla_pago.dart';
import 'package:mobile_app/screens/pantalla_buscar_reporte_original.dart';
import 'package:mobile_app/screens/pantalla_insignias.dart';
import 'package:mobile_app/navigator_key.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  await NotificationService().initialize(navigatorKey);
  await initializeBackgroundService();

  final themeProvider = ThemeProvider();
  final authProvider = AuthNotifier();
  await themeProvider.loadTheme();
  await authProvider.checkAuthStatus();

  if (authProvider.isAuthenticated) {
    SocketService().onStopSos.listen((data) {
      debugPrint("MAIN.DART: Evento stopSos recibido. Invocando al servicio de fondo.");
      FlutterBackgroundService().invoke('serverForceStop', data);
    });
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: authProvider),
      ],
      child: const AlertaPiuraApp(),
    ),
  );
}

class AlertaPiuraApp extends StatelessWidget {
  const AlertaPiuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Reporta Piura',
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.light),
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es', 'ES'),
          ],
          locale: const Locale('es', 'ES'),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/home': (context) => const HomeScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/perfil': (context) => const PerfilScreen(),
            '/editar-perfil': (context) => const EditarPerfilScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/editar-contacto': (context) => const EditarContactoScreen(),
            '/mi_actividad': (context) => MiActividadScreen(mainPageController: PageController()),
            '/cerca_de_ti': (context) => const PantallaCercaDeTi(),
            '/create_report': (context) => const CreateReportScreen(),
            '/conversaciones': (context) => const ConversacionesScreen(),
            '/alertas': (context) => const PantallaAlertas(),
            '/subscription_plans': (context) => const PantallaPlanesSuscripcion(),
            '/historial_pagos': (context) => const PantallaHistorialPagos(),
            '/estadisticas_personales': (context) => const PantallaEstadisticasPersonales(),
            '/alertas_personalizadas': (context) => const PantallaAlertasPersonalizadas(),
            '/crear_zona_segura': (context) => const PantallaCrearZona(),
            '/gestionar_suscripcion': (context) => const PantallaGestionarSuscripcion(),
            '/metodos_pago': (context) => const PantallaMetodosPago(),
            '/agregar_metodo_pago': (context) => const PantallaAgregarMetodoPago(),
            '/panel_analitico': (context) => const PantallaPanelAnalitico(),
            '/mis_informes': (context) => const PantallaInformesGuardados(),
            '/buscar_reporte_original': (context) => const PantallaBuscarReporteOriginal(),
            '/insignias': (context) => const PantallaInsignias(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/reporte_detalle') {
              final args = settings.arguments as int;
              return MaterialPageRoute(builder: (context) => ReporteDetalleScreen(reporteId: args));
            }
            if (settings.name == '/verificacion_detalle') {
              final args = settings.arguments as int;
              return MaterialPageRoute(builder: (context) => VerificacionDetalleScreen(reporteId: args));
            }
            if (settings.name == '/detalle_pendiente_vista') {
              final args = settings.arguments as int;
              return MaterialPageRoute(builder: (context) => PantallaDetallePendienteVista(reporteId: args));
            }
            if (settings.name == '/chat') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(builder: (context) => ChatScreen(reporteId: args['reporteId'], reporteTitulo: args['reporteTitulo']));
            }
            if (settings.name == '/detalle_boleta') {
              final args = settings.arguments as String;
              return MaterialPageRoute(builder: (context) => PantallaDetalleBoleta(transactionId: args));
            }
            if (settings.name == '/pago') {
              final args = settings.arguments as PlanSuscripcion;
              return MaterialPageRoute(builder: (context) => PantallaPago(plan: args));
            }
            return null;
          },
        );
      },
    );
  }
}