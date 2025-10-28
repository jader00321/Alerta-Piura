import 'package:flutter/material.dart';
import 'package:mobile_app/api/perfil_service.dart';

/// {@template dialogo_postulacion_lider}
/// Diálogo [AlertDialog] que contiene el formulario para que un usuario
/// con rol 'ciudadano' postule al rol de 'lider_vecinal'.
///
/// Recopila la motivación y la zona propuesta, valida los campos y envía
/// la postulación a través de [PerfilService.postularComoLider].
/// Se muestra desde [PerfilScreen].
/// {@endtemplate}
class DialogoPostulacionLider extends StatefulWidget {
  /// {@macro dialogo_postulacion_lider}
  const DialogoPostulacionLider({super.key});

  @override
  State<DialogoPostulacionLider> createState() =>
      _DialogoPostulacionLiderState();
}

/// Estado para [DialogoPostulacionLider].
///
/// Maneja el [GlobalKey] del formulario, los [TextEditingController]s,
/// el estado de carga y los mensajes de error.
class _DialogoPostulacionLiderState extends State<DialogoPostulacionLider> {
  final _formKey = GlobalKey<FormState>();
  final _motivacionController = TextEditingController();
  final _zonaController = TextEditingController();
  final PerfilService _perfilService = PerfilService();

  /// Indica si se está procesando el envío de la postulación.
  bool _isLoading = false;
  /// Mensaje de error a mostrar si la postulación falla.
  String? _errorMessage;

  @override
  void dispose() {
    _motivacionController.dispose();
    _zonaController.dispose();
    super.dispose();
  }

  /// Valida el formulario y envía la postulación a la API.
  ///
  /// Si tiene éxito, cierra el diálogo devolviendo `true`.
  /// Si falla, muestra un mensaje de error dentro del diálogo.
  Future<void> _enviarPostulacion() async {
    // Valida el formulario y evita envíos múltiples.
    if (!_formKey.currentState!.validate() || _isLoading) {
      return;
    }

    // Actualiza la UI para mostrar el estado de carga.
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Limpia errores anteriores.
    });

    try {
      // Llama al servicio de perfil para enviar la postulación.
      final response = await _perfilService.postularComoLider(
        motivacion: _motivacionController.text.trim(),
        zonaPropuesta: _zonaController.text.trim(),
      );

      // Verifica si el widget sigue montado después de la llamada asíncrona.
      if (!mounted) return;

      final message = response['message'] ?? 'Error desconocido';
      final success = response['statusCode'] == 201;

      // Muestra un SnackBar con el resultado (opcional, ya que cerramos el diálogo).
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ));

      if (success) {
        // Cierra el diálogo y devuelve 'true' para indicar éxito.
        Navigator.pop(context, true);
      } else {
        // Muestra el mensaje de error de la API dentro del diálogo.
        setState(() {
          _errorMessage = message;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Maneja errores de conexión u otros errores inesperados.
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
        child: SingleChildScrollView( // Permite scroll si el contenido es largo.
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ajusta el tamaño al contenido.
            children: [
              const Text(
                  'Describe brevemente por qué quieres ser líder y qué zona te gustaría representar.'),
              const SizedBox(height: 24),
              /// Campo para la motivación.
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
              /// Campo para la zona propuesta.
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
              /// Muestra el mensaje de error si existe.
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(_errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        /// Botón Cancelar.
        TextButton(
          // Deshabilitado si está cargando.
          onPressed: _isLoading ? null : () => Navigator.pop(context, false), // Devuelve false al cancelar.
          child: const Text('Cancelar'),
        ),
        /// Botón Enviar.
        ElevatedButton(
          onPressed: _isLoading ? null : _enviarPostulacion,
          child: _isLoading
              // Muestra un spinner si está cargando.
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