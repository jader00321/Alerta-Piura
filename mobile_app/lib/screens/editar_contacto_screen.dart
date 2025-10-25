import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditarContactoScreen extends StatefulWidget {
  const EditarContactoScreen({super.key});
  @override
  State<EditarContactoScreen> createState() => _EditarContactoScreenState();
}

class _EditarContactoScreenState extends State<EditarContactoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _mensajeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadContact();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _mensajeController.dispose();
    super.dispose();
  }

  Future<void> _loadContact() async {
    final prefs = await SharedPreferences.getInstance();
    _nombreController.text = prefs.getString('contactNombre') ?? '';
    _telefonoController.text = prefs.getString('contactTelefono') ?? '';
    _mensajeController.text = prefs.getString('contactMensaje') ?? '¡Necesito ayuda urgente! Mi ubicación es:';
  }

  Future<void> _saveContact() async {
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('contactNombre', _nombreController.text.trim());
      await prefs.setString('contactTelefono', _telefonoController.text.trim());
      await prefs.setString('contactMensaje', _mensajeController.text.trim());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contacto de emergencia guardado con éxito.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacto de Emergencia')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Datos del Contacto',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Esta es la persona que recibirá una alerta por SMS cuando actives la función SOS.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Contacto',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) => value!.trim().isEmpty ? 'El nombre es requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _telefonoController,
                        decoration: const InputDecoration(
                          labelText: 'Número de Teléfono',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value!.trim().isEmpty ? 'El número es requerido' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mensaje de Alerta',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Este será el mensaje enviado. Tu ubicación se añadirá automáticamente al final.',
                         style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _mensajeController,
                        decoration: const InputDecoration(
                          labelText: 'Mensaje Personalizado',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        validator: (value) => value!.trim().isEmpty ? 'El mensaje no puede estar vacío' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveContact,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                      )
                    : const Text('Guardar Contacto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}