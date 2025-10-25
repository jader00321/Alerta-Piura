import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/auth_provider.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();
    final bool isLider = authNotifier.isLider;

    void navigateOrPromptLogin(String routeName) {
      if (authNotifier.isAuthenticated) {
        Navigator.pushNamed(context, routeName);
      } else {
        Navigator.pushNamed(context, '/login');
      }
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Card(
        margin: const EdgeInsets.all(16.0),
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.0),
          child: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(child: _buildNavItem(context, Icons.explore_outlined, 'Explorar', isActive: true)),
                Expanded(child: _buildNavItem(context, Icons.location_on_outlined, 'Cerca de Ti', onTap: () => navigateOrPromptLogin('/cerca_de_ti'))),
                const SizedBox(width: 56), 
                if (isLider)
                  Expanded(child: _buildNavItem(context, Icons.verified_user_outlined, 'Verificar', onTap: () => navigateOrPromptLogin('/verificacion')))
                else
                  Expanded(child: _buildNavItem(context, Icons.history_outlined, 'Actividad', onTap: () => navigateOrPromptLogin('/mi_actividad'))),
                Expanded(child: _buildNavItem(context, Icons.notifications_outlined, 'Alertas', onTap: () => navigateOrPromptLogin('/alertas'))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // FIX: Se usa FittedBox para asegurar que el contenido siempre encaje
  Widget _buildNavItem(BuildContext context, IconData icon, String label, {bool isActive = false, VoidCallback? onTap}) {
    final color = isActive ? Theme.of(context).colorScheme.primary : Colors.grey[600];
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}