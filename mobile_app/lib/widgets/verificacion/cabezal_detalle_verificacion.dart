// lib/widgets/verificacion/cabezal_detalle_verificacion.dart
import 'package:flutter/material.dart';
// Ya no necesitamos ReporteDetallado aquí

// Convertimos la clase a una función estática o standalone que devuelve un AppBar
// para mantener la organización, o puedes mover esta lógica directamente
// al AppBar de VerificacionDetalleScreen. Usaremos una función estática aquí.

class CabezalDetalleVerificacion { // Mantenemos la clase como contenedor de la función
  static AppBar buildAppBar(BuildContext context, {
    required bool isLoadingAction,
    required VoidCallback onEditar,
    required VoidCallback onChat,
    required String? reporteEstado, // Necesitamos el estado para la lógica condicional
  }) {
    return AppBar(
      title: const Text('Verificar Reporte'), // Título fijo
      actions: [
        // Botones solo visibles si el reporte está pendiente
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