import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Para debugPrint
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/providers/theme_provider.dart';
import 'package:mobile_app/services/background_service.dart';
import 'package:mobile_app/services/notification_service.dart';
import 'package:mobile_app/services/socket_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

// Importación de todas las pantallas
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
import 'package:mobile_app/providers/map_preferences_provider.dart';
import 'package:mobile_app/screens/pantalla_gestionar_ubicaciones.dart';
import 'package:mobile_app/providers/notification_provider.dart';

/// {@template main}
/// Punto de entrada principal de la aplicación Reporta Piura.
///
/// Esta función `main` es responsable de:
/// 1. Inicializar los bindings de Flutter.
/// 2. Configurar la localización de fechas a español (`es_ES`).
/// 3. Inicializar los servicios globales:
///    - [NotificationService]: Para notificaciones locales (y le pasa la [navigatorKey]).
///    - [BackgroundService]: Para el servicio en segundo plano del SOS.
/// 4. Inicializar los proveedores de estado globales:
///    - [ThemeProvider]: Carga la preferencia de tema (claro/oscuro).
///    - [AuthNotifier]: Carga el token de autenticación guardado (`checkAuthStatus`).
/// 5. Configurar el listener global de [SocketService] para `onStopSos`.
/// 6. Ejecutar la aplicación (`runApp`) envolviéndola en un [MultiProvider].
/// {@endtemplate}
void main() async {
  // 1. Inicialización de Bindings
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Configuración de Localización
  await initializeDateFormatting('es_ES', null);

  // 3. Inicialización de Servicios
  await NotificationService().initialize(navigatorKey);
  await initializeBackgroundService();

  // 4. Inicialización de Providers
  final themeProvider = ThemeProvider();
  final authProvider = AuthNotifier();
  final mapProvider = MapPreferencesProvider();

  /// Carga el tema desde SharedPreferences.
  await themeProvider.loadTheme();

  /// Carga el token desde SharedPreferences ANTES de construir la UI.
  await authProvider.checkAuthStatus();

  /// Carga las preferencias del mapa (ubicaciones guardadas).
  await mapProvider.loadPreferences();

  // 5. Configuración de Listeners Globales
  /// Si el usuario ya está autenticado al abrir la app, conectar el listener
  /// que escucha si un admin detiene su SOS remotamente.
  if (authProvider.isAuthenticated) {
    SocketService().onStopSos.listen((data) {
      debugPrint(
          "MAIN.DART: Evento stopSos recibido. Invocando al servicio de fondo.");

      /// Invoca al servicio en segundo plano (Isolate) para que se detenga.
      FlutterBackgroundService().invoke('serverForceStop', data);
    });
  }

  // 6. Ejecución de la App
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: mapProvider),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const AlertaPiuraApp(),
    ),
  );
}

/// {@template alerta_piura_app}
/// El widget raíz [MaterialApp] de la aplicación.
///
/// Construye la aplicación con:
/// - Gestión de Temas (Claro/Oscuro) consumiendo [ThemeProvider].
/// - Asignación de la [navigatorKey] global.
/// - Configuración de Localización (delegados para `es_ES`).
/// - Definición de todas las rutas de navegación nombradas (`routes`) y
///   rutas con argumentos (`onGenerateRoute`).
/// {@endtemplate}
class AlertaPiuraApp extends StatelessWidget {
  /// {@macro alerta_piura_app}
  const AlertaPiuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    /// Consumer para que [MaterialApp] se reconstruya si cambia el tema.
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Reporta Piura',

          /// Asigna la clave global para navegación desde fuera del BuildContext.
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          /// Definición del Tema Claro
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal, brightness: Brightness.light),
            useMaterial3: true,
            brightness: Brightness.light,
          ),

          /// Definición del Tema Oscuro
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            brightness: Brightness.dark,
          ),

          /// Configuración de Localización
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es', 'ES'),
          ],
          locale: const Locale('es', 'ES'),

          /// Rutas de Navegación
          initialRoute: '/',
          routes: {
            /// Rutas Estáticas (sin argumentos)
            '/': (context) => const SplashScreen(),
            '/home': (context) => const HomeScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/perfil': (context) => const PerfilScreen(),
            '/editar-perfil': (context) => const EditarPerfilScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/editar-contacto': (context) => const EditarContactoScreen(),
            '/mi_actividad': (context) =>
                MiActividadScreen(mainPageController: PageController()),
            '/cerca_de_ti': (context) => const PantallaCercaDeTi(),
            '/create_report': (context) => const CreateReportScreen(),
            '/conversaciones': (context) => const ConversacionesScreen(),
            '/alertas': (context) => const PantallaAlertas(),
            '/subscription_plans': (context) =>
                const PantallaPlanesSuscripcion(),
            '/historial_pagos': (context) => const PantallaHistorialPagos(),
            '/estadisticas_personales': (context) =>
                const PantallaEstadisticasPersonales(),
            '/alertas_personalizadas': (context) =>
                const PantallaAlertasPersonalizadas(),
            '/crear_zona_segura': (context) => const PantallaCrearZona(),
            '/gestionar_suscripcion': (context) =>
                const PantallaGestionarSuscripcion(),
            '/metodos_pago': (context) => const PantallaMetodosPago(),
            '/agregar_metodo_pago': (context) =>
                const PantallaAgregarMetodoPago(),
            '/panel_analitico': (context) => const PantallaPanelAnalitico(),
            '/mis_informes': (context) => const PantallaInformesGuardados(),
            '/buscar_reporte_original': (context) =>
                const PantallaBuscarReporteOriginal(),
            '/insignias': (context) => const PantallaInsignias(),
            '/gestionar_ubicaciones': (context) =>
                const PantallaGestionarUbicaciones(),
          },

          /// Rutas Dinámicas (con argumentos)
          onGenerateRoute: (settings) {
            if (settings.name == '/reporte_detalle') {
              final args = settings.arguments as int;
              return MaterialPageRoute(
                  builder: (context) => ReporteDetalleScreen(reporteId: args));
            }
            if (settings.name == '/verificacion_detalle') {
              final args = settings.arguments as int;
              return MaterialPageRoute(
                  builder: (context) =>
                      VerificacionDetalleScreen(reporteId: args));
            }
            if (settings.name == '/detalle_pendiente_vista') {
              // 1. Obtenemos los argumentos sin forzar el tipo todavía
              final args = settings.arguments;
              int id;

              // 2. Verificamos si es un Mapa (nueva lógica) o un Entero (lógica antigua/notificaciones)
              if (args is Map) {
                id = args['id']; // Extraemos el ID del mapa
              } else {
                id = args as int; // Asumimos que es solo el ID
              }

              // 3. Pasamos el ID al constructor. El widget leerá el resto de datos del mapa internamente.
              return MaterialPageRoute(
                builder: (_) => PantallaDetallePendienteVista(reporteId: id),
                settings:
                    settings, // IMPORTANTE: Pasar settings para que el widget pueda leer los argumentos extra
              );
            }
            if (settings.name == '/chat') {
              int rId = 0;
              String rTitle = 'Chat';
              bool fromDetails = false;

              if (settings.arguments is Map) {
                final args = settings.arguments as Map<String, dynamic>;
                rId = args['reporteId'] ?? 0;
                rTitle = args['reporteTitulo'] ?? 'Chat';
                // Si viene desde una notificación, probablemente queremos que pueda ir al reporte
                fromDetails = args['fromReportDetails'] ?? false;
              }

              return MaterialPageRoute(
                  builder: (context) => ChatScreen(
                      reporteId: rId,
                      reporteTitulo: rTitle,
                      fromReportDetails: fromDetails));
            }
            if (settings.name == '/detalle_boleta') {
              final args = settings.arguments as String;
              return MaterialPageRoute(
                  builder: (context) =>
                      PantallaDetalleBoleta(transactionId: args));
            }
            if (settings.name == '/pago') {
              final args = settings.arguments as PlanSuscripcion;
              return MaterialPageRoute(
                  builder: (context) => PantallaPago(plan: args));
            }
            return null; // Ruta no encontrada
          },
        );
      },
    );
  }
}
