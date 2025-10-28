import 'package:flutter/material.dart';

/// {@template cabezal_detalle_verificacion}
/// Clase de utilidad para construir el [AppBar] de la pantalla [VerificacionDetalleScreen].
///
/// Proporciona un método estático [buildAppBar] que configura el título y
/// muestra condicionalmente los botones de acción (Editar, Chat) si el reporte
/// está en estado 'pendiente_verificacion'.
/// {@endtemplate}
class CabezalDetalleVerificacion {
  /// Construye y devuelve el [AppBar] configurado para la pantalla de detalle de verificación.
  ///
  /// [context]: El [BuildContext] de la pantalla.
  /// [isLoadingAction]: Si es `true`, deshabilita los botones de acción.
  /// [onEditar]: Callback para el botón de editar.
  /// [onChat]: Callback para el botón de chat.
  /// [reporteEstado]: El estado actual del reporte ('pendiente_verificacion', 'verificado', etc.).
  static AppBar buildAppBar(
    BuildContext context, {
    required bool isLoadingAction,
    required VoidCallback onEditar,
    required VoidCallback onChat,
    required String? reporteEstado,
  }) {
    return AppBar(
      title: const Text('Verificar Reporte'),
      actions: [
        // Muestra botones de Editar y Chat solo si el reporte está pendiente
        if (reporteEstado == 'pendiente_verificacion') ...[
          IconButton(
            icon: const Icon(Icons.edit_note_outlined),
            onPressed: isLoadingAction ? null : onEditar,
            tooltip: 'Editar Reporte',
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: isLoadingAction ? null : onChat,
            tooltip: 'Abrir Chat',
          ),
        ]
      ],
    );
  }
}