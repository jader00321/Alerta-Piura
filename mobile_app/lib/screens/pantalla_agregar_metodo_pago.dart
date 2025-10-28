import 'package:flutter/material.dart';
import 'package:mobile_app/api/metodo_pago_service.dart';
import 'package:mobile_app/widgets/pago/formulario_pago.dart';

/// {@template pantalla_agregar_metodo_pago}
/// Pantalla de formulario para añadir un nuevo método de pago (tarjeta).
///
/// Utiliza el widget reutilizable [FormularioPago] para los campos de la tarjeta.
/// {@endtemplate}
class PantallaAgregarMetodoPago extends StatefulWidget {
  /// {@macro pantalla_agregar_metodo_pago}
  const PantallaAgregarMetodoPago({super.key});
  @override
  State<PantallaAgregarMetodoPago> createState() =>
      _PantallaAgregarMetodoPagoState();
}

/// Estado para [PantallaAgregarMetodoPago].
class _PantallaAgregarMetodoPagoState
    extends State<PantallaAgregarMetodoPago> {
  final _formKey = GlobalKey<FormState>();
  final _numeroTarjetaController = TextEditingController();
  final _fechaExpController = TextEditingController();
  final _cvcController = TextEditingController();
  final _nombreTitularController = TextEditingController();
  bool _esPredeterminado = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _numeroTarjetaController.dispose();
    _fechaExpController.dispose();
    _cvcController.dispose();
    _nombreTitularController.dispose();
    super.dispose();
  }

  /// Valida el formulario y envía los datos de la nueva tarjeta a
  /// [MetodoPagoService.crearMetodo].
  Future<void> _guardarMetodo() async {
    if (!_formKey.currentState!.validate() || _isLoading) {
      return;
    }
    setState(() => _isLoading = true);

    final datosTarjeta = {
      'nombreTitular': _nombreTitularController.text,
      'numeroTarjeta': _numeroTarjetaController.text.replaceAll(' ', ''),
      'fechaExp': _fechaExpController.text,
      'cvc': _cvcController.text,
      'es_predeterminado': _esPredeterminado,
    };

    final success = await MetodoPagoService().crearMetodo(datosTarjeta);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            success ? 'Tarjeta guardada con éxito.' : 'Error al guardar la tarjeta.'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
      if (success) {
        Navigator.pop(context, true);
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Método de Pago')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormularioPago(
                nombreTitularController: _nombreTitularController,
                numeroTarjetaController: _numeroTarjetaController,
                fechaExpController: _fechaExpController,
                cvcController: _cvcController,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Establecer como método predeterminado'),
                value: _esPredeterminado,
                onChanged: (val) => setState(() => _esPredeterminado = val),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _guardarMetodo,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 3))
                    : const Text('Guardar Tarjeta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}