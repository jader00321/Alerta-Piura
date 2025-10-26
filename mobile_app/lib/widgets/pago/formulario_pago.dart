// lib/widgets/pago/formulario_pago.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormularioPago extends StatelessWidget {
  // ELIMINAMOS formKey de los parámetros
  final TextEditingController numeroTarjetaController;
  final TextEditingController fechaExpController;
  final TextEditingController cvcController;
  final TextEditingController nombreTitularController;

  const FormularioPago({
    super.key,
    required this.numeroTarjetaController,
    required this.fechaExpController,
    required this.cvcController,
    required this.nombreTitularController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        // ELIMINAMOS EL WIDGET 'Form' ANIDADO. AHORA ES SOLO UN 'Column'.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Información de Pago',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            TextFormField(
              controller: nombreTitularController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Titular',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) => (value?.trim().isEmpty ?? true)
                  ? 'El nombre es requerido'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: numeroTarjetaController,
              decoration: const InputDecoration(
                labelText: 'Número de Tarjeta',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card_outlined),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
                _CardNumberInputFormatter(),
              ],
              validator: (value) =>
                  (value?.replaceAll(' ', '').length ?? 0) != 16
                      ? 'Número de tarjeta inválido'
                      : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: fechaExpController,
                    decoration: const InputDecoration(
                      labelText: 'Expira (MM/AA)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                      _CardExpirationInputFormatter(),
                    ],
                    validator: (value) {
                      if ((value?.length ?? 0) != 5) return 'Fecha inválida';
                      final parts = value!.split('/');
                      final month = int.tryParse(parts[0]);
                      if (month == null || month < 1 || month > 12)
                        return 'Mes inválido';
                      // Podríamos añadir validación de año futuro aquí
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: cvcController,
                    decoration: const InputDecoration(
                      labelText: 'CVC',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    validator: (value) =>
                        (value?.length ?? 0) != 3 ? 'CVC inválido' : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Formatters para una mejor UX en los campos de tarjeta
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

class _CardExpirationInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var newText = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      if (i == 1 && newText.length > 2) {
        buffer.write('/');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}
