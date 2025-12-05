import 'package:flutter/material.dart';
import 'package:mobile_app/api/perfil_service.dart';

class DialogoPostulacionLider extends StatefulWidget {
  const DialogoPostulacionLider({super.key});

  @override
  State<DialogoPostulacionLider> createState() => _DialogoPostulacionLiderState();
}

class _DialogoPostulacionLiderState extends State<DialogoPostulacionLider> {
  final _formKey = GlobalKey<FormState>();
  final PerfilService _perfilService = PerfilService();
  
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _distritos = [
    'Piura', 'Castilla', 'Veintiséis de Octubre', 'Catacaos', 
    'La Unión', 'La Arena', 'Cura Mori', 'El Tallán', 'Las Lomas', 'Tambogrande'
  ];

  final List<String> _motivos = [
    'Mejorar la seguridad de mi barrio',
    'Organizar a los vecinos',
    'Gestionar mantenimiento',
    'Enlace con la municipalidad',
    'Otro'
  ];

  String? _selectedDistrito;
  String? _selectedMotivo;
  final _zonaDetalleController = TextEditingController();
  final _otroMotivoController = TextEditingController();

  @override
  void dispose() {
    _zonaDetalleController.dispose();
    _otroMotivoController.dispose();
    super.dispose();
  }

  Future<void> _enviarPostulacion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String motivoFinal = _selectedMotivo == 'Otro' 
        ? _otroMotivoController.text.trim() 
        : _selectedMotivo!;
        
    final String zonaFinal = '$_selectedDistrito - ${_zonaDetalleController.text.trim()}';

    try {
      final result = await _perfilService.postularComoLider(motivacion: motivoFinal, zonaPropuesta: zonaFinal);

      if (!mounted) return;

      if (result['statusCode'] == 201) {
        Navigator.pop(context, true); // Retorna true indicando éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Postulación enviada! Un administrador la revisará.')),
        );
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Error al enviar la solicitud.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error de conexión.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos LayoutBuilder para saber cuánto espacio tenemos
    return LayoutBuilder(
      builder: (context, constraints) {
        return AlertDialog(
          title: const Text('Postular como Líder'),
          // Hacemos que el contenido sea scrollable y se ajuste
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                // Limitamos el ancho para que no se vea mal en tablets
                maxWidth: 400, 
                // Altura máxima dinámica para evitar overflow con teclado
                maxHeight: constraints.maxHeight * 0.7, 
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Los líderes vecinales ayudan a verificar reportes y organizar su zona.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    
                    DropdownButtonFormField<String>(
                      value: _selectedDistrito,
                      isExpanded: true, // Evita overflow horizontal en textos largos
                      decoration: const InputDecoration(
                        labelText: 'Distrito',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      items: _distritos.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (value) => setState(() => _selectedDistrito = value),
                      validator: (val) => val == null ? 'Selecciona un distrito' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _zonaDetalleController,
                      decoration: const InputDecoration(
                        labelText: 'Barrio o Urbanización',
                        hintText: 'Ej. Urb. Santa María',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value?.trim().isEmpty ?? true) ? 'Especifica tu zona' : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _selectedMotivo,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Motivación Principal',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      items: _motivos.map((m) => DropdownMenuItem(value: m, child: Text(m, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (value) => setState(() => _selectedMotivo = value),
                      validator: (val) => val == null ? 'Selecciona un motivo' : null,
                    ),

                    if (_selectedMotivo == 'Otro') ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _otroMotivoController,
                        decoration: const InputDecoration(
                          labelText: 'Especifica tu motivación',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        validator: (value) => (value?.trim().isEmpty ?? true) ? 'Escribe tu motivo' : null,
                      ),
                    ],

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
          ),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _enviarPostulacion,
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }
}