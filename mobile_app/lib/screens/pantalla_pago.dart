import 'package:flutter/material.dart';
import 'package:mobile_app/api/metodo_pago_service.dart';
import 'package:mobile_app/api/servicio_suscripcion.dart';
import 'package:mobile_app/models/metodo_pago_model.dart';
import 'package:mobile_app/models/plan_suscripcion_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/widgets/pago/resumen_pago.dart';
import 'package:mobile_app/widgets/pago/formulario_pago.dart';

class PantallaPago extends StatefulWidget {
  final PlanSuscripcion plan;
  const PantallaPago({super.key, required this.plan});

  @override
  State<PantallaPago> createState() => _PantallaPagoState();
}

class _PantallaPagoState extends State<PantallaPago> {
  late Future<List<MetodoPago>> _metodosFuture;
  int? _selectedMetodoId;

  final _formKey = GlobalKey<FormState>();
  final _numeroTarjetaController = TextEditingController();
  final _fechaExpController = TextEditingController();
  final _cvcController = TextEditingController();
  final _nombreTitularController = TextEditingController();
  bool _guardarMetodo = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _metodosFuture = MetodoPagoService().listarMetodos();
  }

  @override
  void dispose() {
    _numeroTarjetaController.dispose();
    _fechaExpController.dispose();
    _cvcController.dispose();
    _nombreTitularController.dispose();
    super.dispose();
  }

  Future<void> _submitPayment() async {
    setState(() => _isLoading = true);
    Map<String, dynamic> paymentPayload;

    if (_selectedMetodoId != null) {
      paymentPayload = {'paymentMethodId': _selectedMetodoId};
    } else {
      if (!_formKey.currentState!.validate()) {
        setState(() => _isLoading = false);
        return;
      }
      paymentPayload = {
        'paymentMethod': {
          'nombreTitular': _nombreTitularController.text.trim(),
          'numeroTarjeta': _numeroTarjetaController.text.replaceAll(' ', ''),
          'fechaExp': _fechaExpController.text.trim(),
          'cvc': _cvcController.text.trim(),
          'guardarMetodo': _guardarMetodo,
        }
      };
    }

    final response = await ServicioSuscripcion()
        .suscribirseAlPlan(widget.plan.id, paymentPayload);

    if (!mounted) return;

    if (response['statusCode'] == 200 && response['data']['token'] != null) {
      await context.read<AuthNotifier>().login(response['data']['token']);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('¡Suscripción exitosa!'),
          backgroundColor: Colors.green));
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(response['data']['message'] ?? 'Error al procesar el pago.'),
          backgroundColor: Colors.red));
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar Suscripción')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ResumenPago(plan: widget.plan),
            const SizedBox(height: 24),
            Text('Método de Pago',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            FutureBuilder<List<MetodoPago>>(
              future: _metodosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError ||
                    snapshot.data == null ||
                    snapshot.data!.isEmpty) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        FormularioPago(
                          nombreTitularController: _nombreTitularController,
                          numeroTarjetaController: _numeroTarjetaController,
                          fechaExpController: _fechaExpController,
                          cvcController: _cvcController,
                        ),
                        CheckboxListTile(
                          title:
                              const Text("Guardar tarjeta para futuros pagos"),
                          value: _guardarMetodo,
                          onChanged: (val) =>
                              setState(() => _guardarMetodo = val ?? false),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        )
                      ],
                    ),
                  );
                }

                final metodos = snapshot.data!;
                _selectedMetodoId ??= metodos
                    .firstWhere((m) => m.esPredeterminado,
                        orElse: () => metodos.first)
                    .id;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        ...metodos.map((metodo) => RadioListTile<int>(
                              title: Text(
                                  '${metodo.tipoTarjeta} •••• ${metodo.ultimosCuatroDigitos}'),
                              subtitle:
                                  Text('Expira: ${metodo.fechaExpiracion}'),
                              secondary: metodo.esPredeterminado
                                  ? const Chip(label: Text('Default'))
                                  : null,
                              value: metodo.id,
                              groupValue: _selectedMetodoId,
                              onChanged: (val) =>
                                  setState(() => _selectedMetodoId = val),
                            )),
                        const Divider(),
                        TextButton.icon(
                          icon: const Icon(Icons.add_card),
                          label: const Text('Pagar con otra tarjeta'),
                          onPressed: () => Navigator.pushNamed(
                              context, '/agregar_metodo_pago'),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitPayment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 3))
                  : const Text('Confirmar y Pagar'),
            ),
          ],
        ),
      ),
    );
  }
}
