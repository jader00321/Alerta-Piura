import 'package:flutter/material.dart';
import 'package:mobile_app/api/auth_service.dart';
import 'package:mobile_app/widgets/registro/register_header.dart';
import 'package:mobile_app/widgets/registro/register_form_fields.dart';
import 'package:mobile_app/widgets/registro/register_actions.dart';

/// {@template register_screen}
/// Pantalla de registro para nuevos usuarios.
///
/// Permite al usuario ingresar sus datos (nombre, alias, email, teléfono, contraseña)
/// y enviarlos a la API para crear una nueva cuenta.
/// Utiliza widgets reutilizables como [RegisterHeader], [RegisterFormFields] y [RegisterActions].
/// {@endtemplate}
class RegisterScreen extends StatefulWidget {
  /// {@macro register_screen}
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

/// Estado para [RegisterScreen]. Maneja los controladores y el estado de carga.
class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _aliasController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  /// Indica si se está procesando la solicitud de registro.
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

  /// Valida el formulario y envía la solicitud de registro a la API.
  ///
  /// Si tiene éxito, muestra un [SnackBar] y cierra la pantalla.
  /// Si falla, muestra un [SnackBar] con el error.
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() => _isLoading = true);

      try {
        final response = await _authService.register(
          nombre: _nombreController.text.trim(),
          alias: _aliasController.text.trim().isEmpty
              ? null
              : _aliasController.text.trim(), // Enviar null si está vacío
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          telefono: _telefonoController.text.trim().isEmpty
              ? null
              : _telefonoController.text.trim(), // Enviar null si está vacío
        );

        if (!mounted) return;

        if (response['statusCode'] == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Registro exitoso! Ya puedes iniciar sesión.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Cierra la pantalla de registro
        } else {
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
                const RegisterHeader(),
                const SizedBox(height: 32),
                RegisterFormFields(
                  nombreController: _nombreController,
                  aliasController: _aliasController,
                  emailController: _emailController,
                  telefonoController: _telefonoController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                ),
                const SizedBox(height: 32),
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