import 'package:flutter/material.dart';

class IndicadorRiesgo extends StatelessWidget {
  final int riesgoScore;
  const IndicadorRiesgo({super.key, required this.riesgoScore});

  ({Color color, String label}) _getRiskLevel(int score) {
    if (score > 40)
      return (color: Colors.red.shade700, label: 'Zona Peligrosa');
    if (score > 20)
      return (color: Colors.orange.shade700, label: 'Zona Insegura');
    if (score > 5) return (color: Colors.yellow.shade800, label: 'Precaución');
    return (color: Colors.green.shade700, label: 'Zona Tranquila');
  }

  @override
  Widget build(BuildContext context) {
    final riskLevel = _getRiskLevel(riesgoScore);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey<String>(riskLevel.label),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: riskLevel.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Text(
          riskLevel.label,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
