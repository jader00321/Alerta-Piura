import 'package:flutter/material.dart';

class PulsingPin extends StatefulWidget {
  const PulsingPin({super.key});

  @override
  State<PulsingPin> createState() => _PulsingPinState();
}

class _PulsingPinState extends State<PulsingPin> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: 40 * _controller.value,
                  height: 40 * _controller.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(1 - _controller.value),
                  ),
                );
              },
            ),
            const Icon(Icons.location_on, color: Colors.blue, size: 40),
          ],
        ),
      ),
    );
  }
}