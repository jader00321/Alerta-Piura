import 'package:flutter/material.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/providers/notification_provider.dart'; // <-- IMPORTAR
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
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    
    // Cargar conteo de notificaciones al iniciar la app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthNotifier>();
      if (auth.isAuthenticated) {
        context.read<NotificationProvider>().loadUnreadCount();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    final authNotifier = context.read<AuthNotifier>();
    if (!authNotifier.isAuthenticated && index > 0) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    final authNotifier = context.read<AuthNotifier>();
    if (!authNotifier.isAuthenticated && index > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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

    final List<Widget> pages = [
      const MapaView(),
      const PantallaCercaDeTi(),
      isLider
          ? VerificacionScreen(mainPageController: _pageController)
          : MiActividadScreen(mainPageController: _pageController),
      const PerfilScreen(),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: _selectedIndex == 2
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
          ),/*
          // --- ÍTEM DE PERFIL CON INDICADOR DE NOTIFICACIÓN ---
          BottomNavigationBarItem(
            icon: Consumer<NotificationProvider>(
              builder: (context, notifProvider, child) {
                return Stack(
                  children: [
                    const Icon(Icons.person_outline),
                    if (notifProvider.unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 10,
                            minHeight: 10,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            activeIcon: Consumer<NotificationProvider>(
              builder: (context, notifProvider, child) {
                return Stack(
                  children: [
                    const Icon(Icons.person),
                    if (notifProvider.unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 10,
                            minHeight: 10,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            label: 'Perfil',
          ),*/
        ],
      ),
    );
  }
}