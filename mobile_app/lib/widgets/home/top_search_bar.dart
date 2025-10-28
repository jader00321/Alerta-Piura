import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/auth_provider.dart';

/// {@template top_search_bar}
/// Widget que representa la barra de búsqueda superior en [MapaView].
///
/// Se posiciona en la parte superior de la pantalla (generalmente dentro de un [Stack]).
/// Incluye un campo de texto para buscar reportes (controlado por [onSearchChanged])
/// y un avatar de perfil [CircleAvatar] que funciona como botón.
///
/// El avatar muestra la inicial del usuario si está autenticado ([AuthNotifier.isAuthenticated])
/// o un icono de persona si es un invitado. Al tocarlo, navega a [PerfilScreen]
/// o [LoginScreen] respectivamente.
/// {@endtemplate}
class TopSearchBar extends StatelessWidget {
  /// Callback que se ejecuta cada vez que el texto en el campo de búsqueda cambia.
  /// El [MapaView] utiliza esto para aplicar un debounce y filtrar los reportes.
  final Function(String) onSearchChanged;

  /// {@macro top_search_bar}
  const TopSearchBar({
    super.key,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    /// Observa el [AuthNotifier] para reaccionar a cambios en la autenticación
    /// (ej. cambiar el avatar después de iniciar sesión).
    final authNotifier = context.watch<AuthNotifier>();

    // SafeArea asegura que la barra no se solape con la barra de estado del sistema.
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            /// Campo de texto de búsqueda dentro de una [Card].
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
                    border: InputBorder.none, // Sin borde, la Card lo provee
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14.0),
                  ),
                  onChanged: onSearchChanged, // Llama al callback en cada cambio
                ),
              ),
            ),
            const SizedBox(width: 12),
            /// Avatar/Botón de Perfil.
            GestureDetector(
              onTap: () {
                // Navega a Perfil si está autenticado, si no a Login.
                if (authNotifier.isAuthenticated) {
                  Navigator.pushNamed(context, '/perfil');
                } else {
                  Navigator.pushNamed(context, '/login');
                }
              },
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: authNotifier.isAuthenticated &&
                        authNotifier.userAlias != null
                    // Muestra la inicial del alias si está autenticado.
                    ? Text(
                        authNotifier.userAlias![0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    // Muestra icono de persona si es invitado.
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
  }
}