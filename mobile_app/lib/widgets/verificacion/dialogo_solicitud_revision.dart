import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_historial_moderado_model.dart';

/// {@template dialogo_solicitud_revision}
/// Diálogo [AlertDialog] que permite a un líder ingresar un motivo para
/// solicitar una revisión administrativa de un reporte que ya ha moderado.
///
/// Se muestra al presionar "Solicitar Revisión" en [TarjetaHistorialModerado].
/// {@endtemplate}
class DialogoSolicitudRevision extends StatefulWidget {
  /// El reporte del historial para el cual se solicita la revisión (para contexto).
  final ReporteHistorialModerado reporte;

  /// {@macro dialogo_solicitud_revision}
  const DialogoSolicitudRevision({super.key, required this.reporte});

  @override
  State<DialogoSolicitudRevision> createState() =>
      _DialogoSolicitudRevisionState();
}

/// Estado para [DialogoSolicitudRevision].
///
/// Maneja el [TextEditingController] para el motivo y la validación del formulario.
class _DialogoSolicitudRevisionState extends State<DialogoSolicitudRevision> {
  final _formKey = GlobalKey<FormState>();
  final _motivoController = TextEditingController();
  
  /// Indica si se está procesando el envío (actualmente no se usa aquí,
  /// la llamada API ocurre en el widget padre).
  final bool _isLoading = false; // Mantenido por si se añade lógica de carga aquí

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  /// Valida el formulario y cierra el diálogo, devolviendo el motivo ingresado.
  void _enviar() {
    if (_formKey.currentState!.validate()) {
      // Devuelve el texto del motivo al widget que llamó showDialog
      Navigator.pop(context, _motivoController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Solicitar Revisión'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Muestra información básica del reporte como contexto.
              Text('Reporte: "${widget.reporte.titulo}"'),
              Text('Estado: ${widget.reporte.estado}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              // Campo para ingresar el motivo de la solicitud.
              TextFormField(
                controller: _motivoController,
                decoration: const InputDecoration(
                  labelText: 'Motivo de la Solicitud',
                  hintText:
                      'Ej. "Error al rechazar", "Necesita corrección de datos"...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Debes ingresar un motivo'
                    : null,
              ),
              // Chips con motivos comunes para facilitar el llenado.
              Wrap(
                spacing: 8.0,
                children: [
                  ActionChip(
                      label: const Text('Corregir datos'),
                      onPressed: () => _motivoController.text = 'Corregir datos'),
                  ActionChip(
                      label: const Text('Reevaluar estado'),
                      onPressed: () => _motivoController.text = 'Reevaluar estado'),
                ],
              )
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, null), // Devuelve null si cancela
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _enviar,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Enviar Solicitud'),
        ),
      ],
    );
  }
}