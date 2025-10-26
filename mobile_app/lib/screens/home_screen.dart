// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/screens/mapa_view.dart';
import 'package:mobile_app/screens/mi_actividad_screen.dart';
import 'package:mobile_app/screens/pantalla_cerca_de_ti.dart';
import 'package:mobile_app/screens/perfil_screen.dart';
import 'package:mobile_app/screens/verificacion_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  // PageController para controlar el PageView
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Llamado cuando se toca un ítem de la barra de navegación
  void _onItemTapped(int index) {
    // Si el usuario no está autenticado y toca una pestaña protegida
    final authNotifier = context.read<AuthNotifier>();
    if (!authNotifier.isAuthenticated && index > 0) {
      Navigator.pushNamed(context, '/login');
      return; // No cambiar de página
    }

    // Animar suavemente a la página seleccionada
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    // El _selectedIndex se actualizará en el callback onPageChanged
  }

  /// Llamado cuando el PageView cambia de página (por swipe)
  void _onPageChanged(int index) {
    final authNotifier = context.read<AuthNotifier>();
    if (!authNotifier.isAuthenticated && index > 0) {
      // Prevenir swipe a pestañas protegidas si no está logueado
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pageController.animateToPage(
          0, // Forzar regreso al mapa
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();
    final isLider = authNotifier.isLider;

    // --- Lista de páginas ---
    // Pasamos el _pageController a las pantallas hijas que lo necesitan
    final List<Widget> pages = [
      const MapaView(),
      const PantallaCercaDeTi(),
      isLider
          ? VerificacionScreen(mainPageController: _pageController)
          : MiActividadScreen(mainPageController: _pageController),
      const PerfilScreen(),
    ];
    // --- Fin Lista de páginas ---

    return Scaffold(
      // --- Usamos PageView en lugar de IndexedStack ---
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: pages,
        // --- LÓGICA DE FÍSICA DE SCROLL (CLAVE) ---
        // Deshabilitamos el swipe horizontal del PageView principal
        // SOLAMENTE si la pestaña actual es la 2 (Actividad/Verificar),
        // para permitir que el TabBarView interno maneje el swipe.
        // En todas las demás pestañas (Mapa, Cerca, Perfil), el swipe SÍ funciona.
        physics: _selectedIndex == 2
            ? const NeverScrollableScrollPhysics() // Deshabilitar swipe
            : const PageScrollPhysics(), // Habilitar swipe
        // --- FIN LÓGICA DE FÍSICA ---
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Mantiene el layout fijo
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Llama a _onItemTapped al tocar
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            activeIcon: Icon(Icons.location_on),
            label: 'Cerca de Ti',
          ),
          // El ítem cambia dinámicamente según el rol
          if (isLider)
            const BottomNavigationBarItem(
              icon: Icon(Icons.verified_user_outlined),
              activeIcon: Icon(Icons.verified_user),
              label: 'Verificar',
            )
          else
            const BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'Actividad',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
