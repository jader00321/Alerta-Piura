import 'package:flutter/material.dart';

/// {@template register_form_fields}
/// Widget que agrupa todos los campos de entrada ([TextFormField]) necesarios
/// para el formulario de registro de [RegisterScreen].
///
/// Incluye campos para nombre, alias, email, teléfono, contraseña y confirmación
/// de contraseña, con sus respectivas validaciones y un botón para
/// mostrar/ocultar la contraseña.
/// {@endtemplate}
class RegisterFormFields extends StatefulWidget {
  /// Controlador para el campo de nombre completo.
  final TextEditingController nombreController;
  /// Controlador para el campo de alias (opcional).
  final TextEditingController aliasController;
  /// Controlador para el campo de correo electrónico.
  final TextEditingController emailController;
  /// Controlador para el campo de teléfono (opcional).
  final TextEditingController telefonoController;
  /// Controlador para el campo de contraseña.
  final TextEditingController passwordController;
  /// Controlador para el campo de confirmación de contraseña.
  final TextEditingController confirmPasswordController;

  /// {@macro register_form_fields}
  const RegisterFormFields({
    super.key,
    required this.nombreController,
    required this.aliasController,
    required this.emailController,
    required this.telefonoController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  State<RegisterFormFields> createState() => _RegisterFormFieldsState();
}

/// Estado para [RegisterFormFields].
///
/// Maneja el estado de visibilidad de la contraseña ([_obscurePassword]).
class _RegisterFormFieldsState extends State<RegisterFormFields> {
  /// Controla si los campos de contraseña ocultan el texto.
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Campo Nombre Completo.
        TextFormField(
          controller: widget.nombreController,
          decoration: InputDecoration(
              labelText: 'Nombre Completo',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          validator: (value) =>
              value!.isEmpty ? 'El nombre es requerido' : null,
        ),
        const SizedBox(height: 16),
        /// Campo Alias (Opcional).
        TextFormField(
          controller: widget.aliasController,
          decoration: InputDecoration(
              labelText: 'Alias (Público, opcional)',
              prefixIcon: const Icon(Icons.alternate_email),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          // Sin validación, ya que es opcional.
        ),
        const SizedBox(height: 16),
        /// Campo Correo Electrónico.
        TextFormField(
          controller: widget.emailController,
          decoration: InputDecoration(
              labelText: 'Correo Electrónico',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          keyboardType: TextInputType.emailAddress,
          validator: (value) => value!.isEmpty || !value.contains('@')
              ? 'Ingresa un correo válido'
              : null,
        ),
        const SizedBox(height: 16),
        /// Campo Teléfono (Opcional).
        TextFormField(
          controller: widget.telefonoController,
          decoration: InputDecoration(
              labelText: 'Teléfono (Opcional)',
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        /// Campo Contraseña.
        TextFormField(
          controller: widget.passwordController,
          obscureText: _obscurePassword, // Oculta el texto si es true.
          decoration: InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            // Botón para alternar visibilidad.
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (value) => value!.length < 6
              ? 'La contraseña debe tener al menos 6 caracteres'
              : null,
        ),
        const SizedBox(height: 16),
        /// Campo Confirmar Contraseña.
        TextFormField(
          controller: widget.confirmPasswordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
              labelText: 'Confirmar Contraseña',
              prefixIcon: const Icon(Icons.lock_person_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          validator: (value) => value != widget.passwordController.text
              ? 'Las contraseñas no coinciden'
              : null,
        ),
      ],
    );
  }
}