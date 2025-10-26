import 'package:flutter/material.dart';
import 'package:mobile_app/api/perfil_service.dart';

class DialogoPostulacionLider extends StatefulWidget {
  const DialogoPostulacionLider({super.key});

  @override
  State<DialogoPostulacionLider> createState() =>
      _DialogoPostulacionLiderState();
}

class _DialogoPostulacionLiderState extends State<DialogoPostulacionLider> {
  final _formKey = GlobalKey<FormState>();
  final _motivacionController = TextEditingController();
  final _zonaController = TextEditingController();
  final PerfilService _perfilService = PerfilService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _motivacionController.dispose();
    _zonaController.dispose();
    super.dispose();
  }

  Future<void> _enviarPostulacion() async {
    if (!_formKey.currentState!.validate() || _isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _perfilService.postularComoLider(
        motivacion: _motivacionController.text.trim(),
        zonaPropuesta: _zonaController.text.trim(),
      );

      if (!mounted) return;

      final message = response['message'] ?? 'Error desconocido';
      final success = response['statusCode'] == 201;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ));

      if (success) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          _errorMessage = message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error de conexión: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Postular como Líder Vecinal'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Describe brevemente por qué quieres ser líder y qué zona te gustaría representar.'),
              const SizedBox(height: 24),
              TextFormField(
                controller: _motivacionController,
                decoration: const InputDecoration(
                  labelText: 'Motivación',
                  hintText: 'Ej. "Quiero ayudar a mi comunidad..."',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'La motivación es requerida'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _zonaController,
                decoration: const InputDecoration(
                  labelText: 'Zona Propuesta',
                  hintText: 'Ej. "Urb. Santa María del Pinar"',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'La zona es requerida'
                    : null,
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(_errorMessage!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _enviarPostulacion,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Enviar Postulación'),
        ),
      ],
    );
  }
}
