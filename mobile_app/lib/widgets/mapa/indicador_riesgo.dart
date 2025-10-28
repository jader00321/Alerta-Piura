import 'package:flutter/material.dart';

/// {@template indicador_riesgo}
/// Widget tipo "Chip" que muestra un indicador visual del nivel de riesgo
/// de la zona que se está visualizando en el mapa.
///
/// Cambia de color y texto (ej. 'Zona Peligrosa', 'Zona Tranquila')
/// basándose en un [riesgoScore] numérico.
/// Utiliza [AnimatedSwitcher] para una transición suave al cambiar el nivel.
/// {@endtemplate}
class IndicadorRiesgo extends StatelessWidget {
  /// El puntaje numérico (calculado por el backend) que representa el riesgo.
  final int riesgoScore;

  /// {@macro indicador_riesgo}
  const IndicadorRiesgo({super.key, required this.riesgoScore});

  /// Determina el color y la etiqueta a mostrar según el [score].
  /// Devuelve un [Record] con el [Color] y el [String] correspondientes.
  ({Color color, String label}) _getRiskLevel(int score) {
    if (score > 40) {
      return (color: Colors.red.shade700, label: 'Zona Peligrosa');
    }
    if (score > 20) {
      return (color: Colors.orange.shade700, label: 'Zona Insegura');
    }
    if (score > 5) {
      return (color: Colors.yellow.shade800, label: 'Precaución');
    }
    // Si el score es 5 o menos
    return (color: Colors.green.shade700, label: 'Zona Tranquila');
  }

  @override
  Widget build(BuildContext context) {
    // Obtiene el nivel de riesgo actual.
    final riskLevel = _getRiskLevel(riesgoScore);

    /// [AnimatedSwitcher] anima el cambio entre widgets (basado en la Key).
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500), // Duración de la transición
      child: Container(
        // La Key (basada en la etiqueta) le dice al AnimatedSwitcher
        // que el widget ha cambiado y debe animar.
        key: ValueKey<String>(riskLevel.label),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: riskLevel.color, // Color de fondo dinámico
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(64), // Sombra sutil
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Text(
          riskLevel.label, // Etiqueta de texto dinámica
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}