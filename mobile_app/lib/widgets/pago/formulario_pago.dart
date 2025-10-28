import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// {@template formulario_pago}
/// Widget reutilizable que encapsula los campos de entrada ([TextFormField])
/// estándar para ingresar los datos de una tarjeta de crédito/débito.
///
/// **Importante:** Este widget *no* contiene su propio [GlobalKey<FormState>],
/// permitiendo que sea incluido dentro de un [Form] padre que gestione la
/// validación general (como en [PantallaPago] y [PantallaAgregarMetodoPago]).
///
/// Incluye formateadores de entrada ([TextInputFormatter]) para mejorar la UX
/// al ingresar el número de tarjeta y la fecha de expiración.
/// {@endtemplate}
class FormularioPago extends StatelessWidget {
  /// Controlador para el campo del número de tarjeta.
  final TextEditingController numeroTarjetaController;
  /// Controlador para el campo de la fecha de expiración (MM/AA).
  final TextEditingController fechaExpController;
  /// Controlador para el campo del CVC.
  final TextEditingController cvcController;
  /// Controlador para el campo del nombre del titular.
  final TextEditingController nombreTitularController;

  /// {@macro formulario_pago}
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
        // Usa un Column para organizar los campos verticalmente.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Información de Pago', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            /// Campo Nombre del Titular.
            TextFormField(
              controller: nombreTitularController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Titular',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) =>
                  (value?.trim().isEmpty ?? true) ? 'El nombre es requerido' : null,
            ),
            const SizedBox(height: 16),
            /// Campo Número de Tarjeta.
            TextFormField(
              controller: numeroTarjetaController,
              decoration: const InputDecoration(
                labelText: 'Número de Tarjeta',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card_outlined),
              ),
              keyboardType: TextInputType.number,
              // Aplica formateadores para dígitos, longitud y espaciado.
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
                _CardNumberInputFormatter(), // Formateador personalizado
              ],
              validator: (value) =>
                  // Valida que tenga 16 dígitos después de quitar espacios.
                  (value?.replaceAll(' ', '').length ?? 0) != 16
                      ? 'Número de tarjeta inválido'
                      : null,
            ),
            const SizedBox(height: 16),
            /// Fila para Fecha de Expiración y CVC.
            Row(
              children: [
                /// Campo Fecha de Expiración (MM/AA).
                Expanded(
                  child: TextFormField(
                    controller: fechaExpController,
                    decoration: const InputDecoration(
                      labelText: 'Expira (MM/AA)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    // Aplica formateadores para dígitos, longitud y formato MM/AA.
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                      _CardExpirationInputFormatter(), // Formateador personalizado
                    ],
                    validator: (value) {
                      // Validación básica de formato y mes.
                      if ((value?.length ?? 0) != 5) {
                        return 'Fecha inválida';
                      }
                      final parts = value!.split('/');
                      final month = int.tryParse(parts[0]);
                      if (month == null || month < 1 || month > 12) {
                        return 'Mes inválido';
                      }
                      // Podría añadirse validación de año futuro aquí.
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                /// Campo CVC.
                Expanded(
                  child: TextFormField(
                    controller: cvcController,
                    decoration: const InputDecoration(
                      labelText: 'CVC',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    // Aplica formateadores para dígitos y longitud.
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

/// [TextInputFormatter] personalizado para añadir espacios cada 4 dígitos
/// al número de tarjeta.
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    // Evita formatear si el cursor está al inicio.
    if (newValue.selection.baseOffset == 0) return newValue;

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      // Añade un espacio después de cada grupo de 4 dígitos, excepto al final.
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }
    var string = buffer.toString();
    // Devuelve el texto formateado y mueve el cursor al final.
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

/// [TextInputFormatter] personalizado para añadir una barra '/' después
/// de los 2 primeros dígitos de la fecha de expiración (MM/AA).
class _CardExpirationInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var newText = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;

    var buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      // Si se han ingresado 2 dígitos y hay más por ingresar, añade la barra.
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