// lib/widgets/home/top_search_bar.dart
import 'package:flutter/material.dart';
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

    // --- REMOVED Positioned WIDGET ---
    // The parent Stack in mapa_view.dart handles positioning.
    // We just return the content directly.
    return SafeArea( // Keep SafeArea for status bar spacing
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por código o título...',
                    prefixIcon: const Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14.0), // Adjust padding as needed
                  ),
                  onChanged: onSearchChanged,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                if (authNotifier.isAuthenticated) {
                  Navigator.pushNamed(context, '/perfil');
                } else {
                  Navigator.pushNamed(context, '/login');
                }
              },
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: authNotifier.isAuthenticated && authNotifier.userAlias != null
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
          ],
        ),
      ),
    );
    // --- END OF REMOVED Positioned WIDGET ---
  }
}