import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditarContactoScreen extends StatefulWidget {
  const EditarContactoScreen({super.key});
  @override
  State<EditarContactoScreen> createState() => _EditarContactoScreenState();
}

class _EditarContactoScreenState extends State<EditarContactoScreen> {
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _mensajeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContact();
  }

  Future<void> _loadContact() async {
    final prefs = await SharedPreferences.getInstance();
    _nombreController.text = prefs.getString('contactNombre') ?? '';
    _telefonoController.text = prefs.getString('contactTelefono') ?? '';
    _mensajeController.text = prefs.getString('contactMensaje') ?? '¡Necesito ayuda urgente!';
  }

  Future<void> _saveContact() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('contactNombre', _nombreController.text);
    await prefs.setString('contactTelefono', _telefonoController.text);
    await prefs.setString('contactMensaje', _mensajeController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contacto de emergencia guardado.')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacto de Emergencia')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre del Contacto')),
          const SizedBox(height: 16),
          TextField(controller: _telefonoController, decoration: const InputDecoration(labelText: 'Número de Teléfono'), keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          TextField(controller: _mensajeController, decoration: const InputDecoration(labelText: 'Mensaje Personalizado (Opcional)'), maxLines: 3),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _saveContact, child: const Text('Guardar Contacto')),
        ],
      ),
    );
  }
}