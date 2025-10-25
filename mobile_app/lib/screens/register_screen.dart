import 'package:flutter/material.dart';
import 'package:mobile_app/api/auth_service.dart';

// Importamos los nuevos widgets que hemos creado
import 'package:mobile_app/widgets/registro/register_header.dart';
import 'package:mobile_app/widgets/registro/register_form_fields.dart';
import 'package:mobile_app/widgets/registro/register_actions.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Los controladores se mantienen en la pantalla principal para gestionar el estado
  final _nombreController = TextEditingController();
  final _aliasController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _nombreController.dispose();
    _aliasController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // La lógica de envío del formulario permanece en la pantalla principal
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() => _isLoading = true);
      
      try {
        final response = await _authService.register(
          nombre: _nombreController.text.trim(),
          alias: _aliasController.text.trim().isNotEmpty ? _aliasController.text.trim() : null,
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          telefono: _telefonoController.text.trim().isNotEmpty ? _telefonoController.text.trim() : null,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['data']['message']),
              backgroundColor: response['statusCode'] == 201 ? Colors.green : Colors.red,
            ),
          );
          if (response['statusCode'] == 201) {
            Navigator.pop(context);
          }
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
        title: const Text('Crear Cuenta'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Usamos el widget de cabecera
                const RegisterHeader(),
                const SizedBox(height: 32),

                // 2. Usamos el widget de campos del formulario, pasándole los controladores
                RegisterFormFields(
                  nombreController: _nombreController,
                  aliasController: _aliasController,
                  emailController: _emailController,
                  telefonoController: _telefonoController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                ),
                const SizedBox(height: 32),

                // 3. Usamos el widget de acciones
                RegisterActions(
                  isLoading: _isLoading,
                  onSubmit: _submitForm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}