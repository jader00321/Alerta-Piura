import 'package:flutter/material.dart';
import 'package:mobile_app/api/auth_service.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final response = await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (response['statusCode'] == 200) {
        final token = response['data']['token'];
        // Use the AuthNotifier to handle the login state
        await Provider.of<AuthNotifier>(context, listen: false).login(token, _rememberMe);

        // Navigate back to home, which will now show the authenticated UI
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['data']['message']),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16.0),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        // Remove the back button as this is a top-level screen
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty || !value.contains('@') ? 'Ingresa un correo válido' : null,
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
                validator: (value) => value!.isEmpty ? 'La contraseña es requerida' : null,
              ),
              CheckboxListTile(
                title: const Text('Recordar Sesión'),
                value: _rememberMe,
                onChanged: (newValue) {
                  setState(() {
                    _rememberMe = newValue!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Iniciar Sesión'),
                    ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // Simply go back to the home screen in its guest state
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                },
                child: const Text('Continuar como Visitante'),
              ),
              TextButton(
                onPressed: () {
                  _emailController.clear();
                  _passwordController.clear();
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('¿No tienes una cuenta? Regístrate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}