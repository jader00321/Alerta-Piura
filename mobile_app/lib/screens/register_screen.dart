import 'package:flutter/material.dart';
import 'package:mobile_app/api/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _aliasController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _telefonoController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    // Limpiamos los controladores para liberar memoria cuando la pantalla se destruye.
    _nombreController.dispose();
    _aliasController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      final response = await _authService.register(
        nombre: _nombreController.text,
        alias: _aliasController.text.isNotEmpty ? _aliasController.text : null,
        email: _emailController.text,
        password: _passwordController.text,
        telefono: _telefonoController.text.isNotEmpty ? _telefonoController.text : null,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['data']['message']),
            backgroundColor: response['statusCode'] == 201 ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
        if (response['statusCode'] == 201) {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre Completo'),
                validator: (value) => value!.isEmpty ? 'El nombre es requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _aliasController,
                decoration: const InputDecoration(labelText: 'Alias (Opcional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty || !value.contains('@') ? 'Ingresa un correo válido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono (Opcional)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) => value!.length < 6 ? 'La contraseña debe tener al menos 6 caracteres' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscurePassword,
                decoration: const InputDecoration(labelText: 'Confirmar Contraseña'),
                validator: (value) => value != _passwordController.text ? 'Las contraseñas no coinciden' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Registrarse'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}