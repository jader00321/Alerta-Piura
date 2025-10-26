import 'package:flutter/material.dart';

class RegisterFormFields extends StatefulWidget {
  final TextEditingController nombreController;
  final TextEditingController aliasController;
  final TextEditingController emailController;
  final TextEditingController telefonoController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

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

class _RegisterFormFieldsState extends State<RegisterFormFields> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: widget.nombreController,
          decoration: InputDecoration(
              labelText: 'Nombre Completo',
              prefixIcon: const Icon(Icons.person_outline),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          validator: (value) =>
              value!.isEmpty ? 'El nombre es requerido' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: widget.aliasController,
          decoration: InputDecoration(
              labelText: 'Alias (Público, opcional)',
              prefixIcon: const Icon(Icons.alternate_email),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: widget.emailController,
          decoration: InputDecoration(
              labelText: 'Correo Electrónico',
              prefixIcon: const Icon(Icons.email_outlined),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          keyboardType: TextInputType.emailAddress,
          validator: (value) => value!.isEmpty || !value.contains('@')
              ? 'Ingresa un correo válido'
              : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: widget.telefonoController,
          decoration: InputDecoration(
              labelText: 'Teléfono (Opcional)',
              prefixIcon: const Icon(Icons.phone_outlined),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          keyboardType: TextInputType.phone,
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
          validator: (value) => value!.length < 6
              ? 'La contraseña debe tener al menos 6 caracteres'
              : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: widget.confirmPasswordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
              labelText: 'Confirmar Contraseña',
              prefixIcon: const Icon(Icons.lock_person_outlined),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          validator: (value) => value != widget.passwordController.text
              ? 'Las contraseñas no coinciden'
              : null,
        ),
      ],
    );
  }
}
