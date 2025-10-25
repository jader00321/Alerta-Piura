// lib/widgets/verificacion/dialogo_solicitud_revision.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/models/reporte_historial_moderado_model.dart'; // Para mostrar info del reporte

class DialogoSolicitudRevision extends StatefulWidget {
  final ReporteHistorialModerado reporte; // Recibe el reporte para contexto

  const DialogoSolicitudRevision({super.key, required this.reporte});

  @override
  State<DialogoSolicitudRevision> createState() => _DialogoSolicitudRevisionState();
}

class _DialogoSolicitudRevisionState extends State<DialogoSolicitudRevision> {
  final _formKey = GlobalKey<FormState>();
  final _motivoController = TextEditingController();
  bool _isLoading = false; // Puedes añadir estado de carga si la llamada API se hiciera aquí

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  void _enviar() {
    if (_formKey.currentState!.validate()) {
      // Devolver el motivo ingresado
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
              Text(
                'Reporte: "${widget.reporte.titulo}" (${widget.reporte.estado})',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              const Text('Indica el motivo por el cual solicitas una revisión para este reporte:'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _motivoController,
                decoration: const InputDecoration(
                  labelText: 'Motivo de la Solicitud',
                  hintText: 'Ej. "Error al rechazar", "Necesita corrección de datos"...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Debes ingresar un motivo'
                    : null,
              ),
              // Recomendación: Podrías añadir aquí botones con motivos comunes
              Wrap(
                 spacing: 8.0,
                 children: [
                   ActionChip(label: Text('Corregir datos'), onPressed: () => _motivoController.text = 'Corregir datos'),
                   ActionChip(label: Text('Reevaluar estado'), onPressed: () => _motivoController.text = 'Reevaluar estado'),
                 ],
              )
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, null), // Devolver null al cancelar
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _enviar,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Enviar Solicitud'),
        ),
      ],
    );
  }
}