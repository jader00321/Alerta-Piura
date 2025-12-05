import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/common/notification_badge.dart'; // <-- IMPORTAR
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/auth_provider.dart';

class TopSearchBar extends StatelessWidget {
  final Function(String) onSearchChanged;

  const TopSearchBar({
    super.key,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            // --- Barra de Búsqueda ---
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: onSearchChanged,
                  decoration: const InputDecoration(
                    hintText: 'Buscar reportes...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),

            // --- Atajo de Notificaciones (NUEVO) ---
            // Solo se muestra si está autenticado
            if (authNotifier.isAuthenticated)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const NotificationBadge(), // <-- Aquí va la campana
              ),

            if (authNotifier.isAuthenticated) const SizedBox(width: 12),

            // --- Avatar de Perfil ---
            GestureDetector(
              onTap: () {
                if (authNotifier.isAuthenticated) {
                  Navigator.pushNamed(context, '/perfil');
                } else {
                  Navigator.pushNamed(context, '/login');
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: authNotifier.isAuthenticated &&
                          authNotifier.userAlias != null
                      ? Text(
                          authNotifier.userAlias![0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 28,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}