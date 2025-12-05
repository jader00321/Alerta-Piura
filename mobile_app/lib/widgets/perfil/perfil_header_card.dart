import 'package:flutter/material.dart';
import 'package:mobile_app/models/perfil_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class PerfilHeaderCard extends StatelessWidget {
  final Perfil perfil;

  const PerfilHeaderCard({super.key, required this.perfil});

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();
    final String role = authNotifier.userRole ?? 'ciudadano';
    final bool isPremium = perfil.nombrePlan != null;

    // --- LÓGICA DE JERARQUÍA VISUAL ---
    LinearGradient backgroundGradient;
    // ignore: unused_local_variable
    Color iconColor;
    String statusLabel;

    // Prioridad 1: Roles Administrativos/Líderes (Tienen peso oficial)
    if (role == 'admin') {
       backgroundGradient = const LinearGradient(colors: [Color(0xFF263238), Color(0xFF455A64)]); // Negro/Gris
       iconColor = Colors.white;
       statusLabel = 'ADMINISTRADOR';
    } else if (role == 'lider_vecinal') {
       // Si es líder, predomina el verde aunque sea premium
       backgroundGradient = const LinearGradient(colors: [Color(0xFF00695C), Color(0xFF4DB6AC)]); // Verde
       iconColor = Colors.white;
       statusLabel = isPremium ? 'LÍDER VECINAL (PREMIUM)' : 'LÍDER VECINAL';
    } else if (role == 'reportero') {
       backgroundGradient = const LinearGradient(colors: [Color(0xFFC62828), Color(0xFFFF7043)]); // Rojo
       iconColor = Colors.white;
       statusLabel = 'PRENSA / REPORTERO';
    } 
    // Prioridad 2: Suscripción Premium (Si no tiene rol oficial)
    else if (isPremium) {
      backgroundGradient = const LinearGradient(colors: [Color(0xFFFFA000), Color(0xFFFFECB3)]); // Dorado
      iconColor = Colors.brown.shade800;
      statusLabel = 'CIUDADANO PREMIUM';
    } 
    // Prioridad 3: Ciudadano Estándar
    else {
      backgroundGradient = LinearGradient(colors: [const Color(0xFF1565C0), Colors.blue.shade300]); // Azul
      iconColor = Colors.white;
      statusLabel = 'CIUDADANO';
    }

    // Color del texto (oscuro para fondo premium, blanco para los demás)
    // Solo si es Premium y NO es un rol oficial (porque los roles oficiales usan fondos oscuros)
    final bool isLightBg = isPremium && role == 'ciudadano';
    final textColor = isLightBg ? Colors.brown.shade900 : Colors.white;
    final subTextColor = isLightBg ? Colors.brown.shade700 : Colors.white70;

    return Card(
      elevation: 8,
      shadowColor: backgroundGradient.colors.first.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: backgroundGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Etiqueta de estatus
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isLightBg ? Colors.white.withOpacity(0.5) : Colors.black26,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: textColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Info Usuario
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: Text(
                      (perfil.alias ?? perfil.nombre)[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: backgroundGradient.colors.first,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        perfil.alias ?? perfil.nombre,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        perfil.email,
                        style: TextStyle(fontSize: 14, color: subTextColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: isLightBg ? Colors.brown : Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${perfil.puntos} Puntos',
                            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}