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