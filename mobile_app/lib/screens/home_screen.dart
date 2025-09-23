import 'package:flutter/material.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/screens/conversaciones_screen.dart';
import 'package:mobile_app/screens/mapa_view.dart';
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
  
  // A PageController to manage the pages without rebuilding them
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    // If the user is a guest and taps a disabled tab, redirect to login.
    final auth = Provider.of<AuthNotifier>(context, listen: false);
    if (!auth.isAuthenticated && index > 0) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthNotifier>(
      builder: (context, auth, child) {
        final isLider = auth.userRole == 'lider_vecinal';
        
        // Define the list of pages (widgets) for the PageView
        List<Widget> pages = [
          const MapaView(),
          if (auth.isAuthenticated) ...[
            if (isLider) const VerificacionScreen(),
            if (isLider) const ConversacionesScreen(),
            const PerfilScreen(),
          ]
        ];
        
        // Define the navigation bar items
        List<BottomNavigationBarItem> items = [
          const BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Mapa'),
        ];

        if (auth.isAuthenticated) {
          if (isLider) {
            items.add(const BottomNavigationBarItem(icon: Icon(Icons.verified_user_outlined), activeIcon: Icon(Icons.verified_user), label: 'Verificar'));
            items.add(const BottomNavigationBarItem(icon: Icon(Icons.message_outlined), activeIcon: Icon(Icons.message), label: 'Mensajes'));
          }
          items.add(const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'));
        } else {
          // Add disabled-looking placeholder tabs for guests
          items.add(const BottomNavigationBarItem(icon: Icon(Icons.verified_user_outlined), label: 'Verificar'));
          items.add(const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'));
        }

        return Scaffold(
          body: PageView(
            controller: _pageController,
            // Prevent manual swiping between pages
            physics: const NeverScrollableScrollPhysics(),
            children: pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: items,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            // Style the bar for guest vs logged-in users
            unselectedItemColor: auth.isAuthenticated ? Colors.grey[600] : Colors.grey[400],
            selectedItemColor: auth.isAuthenticated ? Theme.of(context).colorScheme.primary : Colors.grey[400],
          ),
        );
      }
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/screens/mapa_view.dart';
import 'package:mobile_app/screens/perfil_screen.dart';
import 'package:mobile_app/screens/verificacion_screen.dart';
import 'package:mobile_app/screens/conversaciones_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index, bool isAuthenticated) {
    if (!isAuthenticated && index > 0) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthNotifier>(
      builder: (context, auth, child) {
        final isLider = auth.userRole == 'lider_vecinal';
        
        List<Widget> widgets = [
          const MapaView(),
          if (auth.isAuthenticated) ...[
            if (isLider) const VerificacionScreen(),
            if (isLider) const ConversacionesScreen(),
            const PerfilScreen(),
          ]
        ];
        
        List<BottomNavigationBarItem> items = [
          const BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
        ];

        if (auth.isAuthenticated) {
          if (isLider) {
            items.add(const BottomNavigationBarItem(icon: Icon(Icons.verified_user), label: 'Verificar'));
            items.add(const BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Mensajes'));
          }
          items.add(const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'));
        } else {
          // Add disabled-looking tabs for guests
          items.add(const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'));
        }

        return Scaffold(
          body: Center(
            child: widgets.elementAt(_selectedIndex),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: items,
            currentIndex: _selectedIndex,
            onTap: (index) => _onItemTapped(index, auth.isAuthenticated),
            type: BottomNavigationBarType.fixed,
            unselectedItemColor: auth.isAuthenticated ? null : Colors.grey[400],
            
          ),
        );
      }
    );
  }
}
*/