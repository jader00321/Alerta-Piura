import 'package:flutter/material.dart';

/// {@template pin_pulsante}
/// Widget de animación que muestra un pin de ubicación fijo en el centro
/// con una onda pulsante detrás de él.
///
/// Se usa en [MapaView] para indicar el centro del mapa que se está evaluando
/// para el riesgo de zona.
/// Utiliza [IgnorePointer] para asegurar que no interfiere con los gestos del mapa.
/// {@endtemplate}
class PinPulsante extends StatefulWidget {
  /// {@macro pin_pulsante}
  const PinPulsante({super.key});

  @override
  State<PinPulsante> createState() => _PinPulsanteState();
}

/// Estado para [PinPulsante].
///
/// Maneja el [AnimationController] para la animación de pulsación.
class _PinPulsanteState extends State<PinPulsante>
    with SingleTickerProviderStateMixin {
  /// Controlador de la animación.
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, // Provee el Ticker.
      duration: const Duration(seconds: 2), // Duración de cada ciclo de pulsación.
    )..repeat(reverse: true); // Repite la animación (crece y decrece).
  }

  @override
  void dispose() {
    _controller.dispose(); // Libera el controlador.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      /// [IgnorePointer] evita que este widget capture los gestos (como drag)
      /// que deben ir al mapa que está detrás.
      child: IgnorePointer(
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// [AnimatedBuilder] reconstruye la onda pulsante en cada tick.
            AnimatedBuilder(
              animation: _controller, // Escucha al controlador.
              builder: (context, child) {
                // El contenedor cambia su tamaño y opacidad basado en el
                // valor del controlador (de 0.0 a 1.0 y viceversa).
                return Container(
                  width: 50 * _controller.value, // Tamaño de 0 a 50
                  height: 50 * _controller.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // El color se desvanece a medida que se aleja.
                    color: Colors.blue.withAlpha(
                        (128 * (1 - _controller.value)).round()),
                  ),
                );
              },
            ),
            /// El pin de ubicación estático que se muestra encima de la animación.
            const Icon(Icons.location_pin,
                color: Colors.blue,
                size: 40,
                shadows: [Shadow(blurRadius: 10, color: Colors.black45)]),
          ],
        ),
      ),
    );
  }
}