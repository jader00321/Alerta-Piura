import 'package:flutter/material.dart';

/// {@template login_form_fields}
/// Widget que agrupa los campos de entrada ([TextFormField]) para el
/// formulario de la pantalla de login [LoginScreen].
///
/// Incluye campos para "Correo Electrónico" y "Contraseña", con sus
/// respectivas validaciones y un botón para mostrar/ocultar la contraseña.
/// {@endtemplate}
class LoginFormFields extends StatefulWidget {
  /// Controlador para el campo de texto del email.
  final TextEditingController emailController;
  /// Controlador para el campo de texto de la contraseña.
  final TextEditingController passwordController;

  /// {@macro login_form_fields}
  const LoginFormFields({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<LoginFormFields> createState() => _LoginFormFieldsState();
}

/// Estado para [LoginFormFields].
///
/// Maneja el estado de visibilidad de la contraseña ([_obscurePassword]).
class _LoginFormFieldsState extends State<LoginFormFields> {
  /// Controla si el texto de la contraseña debe ocultarse (ser ofuscado).
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Campo de Correo Electrónico.
        TextFormField(
          controller: widget.emailController,
          decoration: InputDecoration(
            labelText: 'Correo Electrónico',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) =>
              value!.isEmpty || !value.contains('@') ? 'Ingresa un correo válido' : null,
        ),
        const SizedBox(height: 16),
        /// Campo de Contraseña.
        TextFormField(
          controller: widget.passwordController,
          obscureText: _obscurePassword, // Oculta el texto si es true.
          decoration: InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            /// Botón para alternar la visibilidad de la contraseña.
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (value) =>
              value!.isEmpty ? 'La contraseña es requerida' : null,
        ),
      ],
    );
  }
}