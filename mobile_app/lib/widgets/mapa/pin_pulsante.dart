import 'package:flutter/material.dart';

class PinPulsante extends StatefulWidget {
  const PinPulsante({super.key});

  @override
  State<PinPulsante> createState() => _PinPulsanteState();
}

class _PinPulsanteState extends State<PinPulsante> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IgnorePointer( // Para que no interfiera con los gestos del mapa
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: 50 * _controller.value,
                  height: 50 * _controller.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(0.5 * (1 - _controller.value)),
                  ),
                );
              },
            ),
            const Icon(Icons.location_pin, color: Colors.blue, size: 40, shadows: [Shadow(blurRadius: 10, color: Colors.black45)]),
          ],
        ),
      ),
    );
  }
}