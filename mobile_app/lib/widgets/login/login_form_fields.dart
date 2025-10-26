import 'package:flutter/material.dart';

class LoginFormFields extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginFormFields({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<LoginFormFields> createState() => _LoginFormFieldsState();
}

class _LoginFormFieldsState extends State<LoginFormFields> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: widget.emailController,
          decoration: InputDecoration(
            labelText: 'Correo Electrónico',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) => value!.isEmpty || !value.contains('@')
              ? 'Ingresa un correo válido'
              : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: widget.passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (value) =>
              value!.isEmpty ? 'La contraseña es requerida' : null,
        ),
      ],
    );
  }
}
