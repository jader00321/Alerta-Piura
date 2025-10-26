import 'package:flutter/material.dart';

class LoginActions extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onSubmit;

  const LoginActions({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: isLoading ? null : onSubmit,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 3, color: Colors.white),
                )
              : const Text('Iniciar Sesión'),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("¿No tienes una cuenta?"),
            TextButton(
              onPressed: () {
                if (!isLoading) {
                  Navigator.pushNamed(context, '/register');
                }
              },
              child: const Text('Regístrate aquí'),
            ),
          ],
        ),
      ],
    );
  }
}
