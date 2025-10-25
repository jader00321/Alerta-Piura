import 'package:flutter/material.dart';
import 'package:mobile_app/api/auth_service.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

// Importamos los nuevos widgets que hemos creado
import 'package:mobile_app/widgets/login/login_header.dart';
import 'package:mobile_app/widgets/login/login_form_fields.dart';
import 'package:mobile_app/widgets/login/login_actions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // La lógica de envío del formulario se mantiene aquí
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() => _isLoading = true);

      try {
        final response = await _authService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (mounted && response['statusCode'] == 200) {
          final token = response['data']['token'];
          await Provider.of<AuthNotifier>(context, listen: false).login(token);

          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['data']['message'] ?? 'Ocurrió un error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error de conexión. Inténtalo de nuevo.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // El AppBar ahora es transparente y sin elevación para un look más moderno
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Oculta la flecha de "atrás" por defecto
        actions: [
          // --- BOTÓN AÑADIDO PARA VOLVER AL MAPA ---
          IconButton(
            tooltip: 'Volver al mapa',
            icon: const Icon(Icons.close),
            onPressed: () {
              // Navega a la pantalla de inicio y limpia el historial de rutas
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            },
          ),
        ],
      ),
      // ExtendBodyBehindAppBar permite que el cuerpo se dibuje detrás del AppBar
      extendBodyBehindAppBar: true,
      body: Container(
        // Fondo con degradado para un diseño más atractivo
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Usamos el widget de cabecera
                  const LoginHeader(),
                  const SizedBox(height: 40),

                  // 2. Usamos el widget de campos del formulario
                  LoginFormFields(
                    emailController: _emailController,
                    passwordController: _passwordController,
                  ),
                  const SizedBox(height: 24),

                  // 3. Usamos el widget de acciones
                  LoginActions(
                    isLoading: _isLoading,
                    onSubmit: _submitForm,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}