import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// {@template editar_contacto_screen}
/// Pantalla para configurar el contacto de emergencia del sistema SOS.
///
/// Permite definir Nombre, Teléfono y un Mensaje personalizado.
/// Incluye una vista previa visual para que el usuario entienda que el enlace
/// de ubicación se añade automáticamente.
/// {@endtemplate}
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

  /// Carga los datos guardados previamente.
  Future<void> _loadContact() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nombreController.text = prefs.getString('contactNombre') ?? '';
      _telefonoController.text = prefs.getString('contactTelefono') ?? '';
      _mensajeController.text = prefs.getString('contactMensaje') ?? '¡Ayuda! Estoy en peligro, sigue mi ubicación.';
    });
  }

  /// Guarda los datos en SharedPreferences.
  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('contactNombre', _nombreController.text.trim());
    await prefs.setString('contactTelefono', _telefonoController.text.trim());
    await prefs.setString('contactMensaje', _mensajeController.text.trim());

    if (!mounted) return;

    setState(() => _isLoading = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contacto de emergencia actualizado'),
        backgroundColor: Colors.green,
      ),
    );
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacto de Emergencia'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- TARJETA DE INFORMACIÓN ---
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Este contacto recibirá un SMS con un enlace de Google Maps cuando actives la alerta SOS.",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- SECCIÓN 1: DATOS DEL CONTACTO ---
              Text("¿A quién avisar?", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Contacto',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.trim().isEmpty ? 'Ingresa un nombre' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _telefonoController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Número de Teléfono',
                          prefixIcon: Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(),
                          hintText: 'Ej. 912345678'
                        ),
                        validator: (v) => v!.trim().isEmpty ? 'Ingresa un teléfono' : null,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- SECCIÓN 2: MENSAJE PERSONALIZADO ---
              Text("Mensaje de Alerta", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _mensajeController,
                        maxLines: 3,
                        onChanged: (_) => setState(() {}), // Actualizar vista previa
                        decoration: const InputDecoration(
                          labelText: 'Tu mensaje de ayuda',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                          hintText: '¡Ayuda! Estoy en peligro.'
                        ),
                        validator: (v) => v!.trim().isEmpty ? 'El mensaje no puede estar vacío' : null,
                      ),
                      
                      const SizedBox(height: 20),
                      const Text(
                        "VISTA PREVIA DEL SMS:",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      
                      // --- SIMULACIÓN DE BURBUJA DE SMS ---
                      Container(
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                            bottomLeft: Radius.zero, // Pico de burbuja
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _mensajeController.text.isEmpty 
                                  ? "(Escribe un mensaje arriba...)" 
                                  : _mensajeController.text,
                              style: TextStyle(
                                fontSize: 15, 
                                color: theme.textTheme.bodyMedium?.color
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Enlace simulado
                            Text(
                              "📍 https://maps.google.com/?q=-5.1944,-80.6328",
                              style: TextStyle(
                                color: Colors.blue.shade600, 
                                fontWeight: FontWeight.bold,
                                fontSize: 14
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "(Ubicación añadida automáticamente)",
                              style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // --- BOTÓN GUARDAR ---
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveContact,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                icon: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save),
                label: const Text("GUARDAR CONFIGURACIÓN"),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}