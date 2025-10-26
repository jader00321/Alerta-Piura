import 'package:flutter/material.dart';

class RegisterActions extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onSubmit;

  const RegisterActions({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onSubmit,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  strokeWidth: 3, color: Colors.white),
            )
          : const Text('Registrarse'),
    );
  }
}
