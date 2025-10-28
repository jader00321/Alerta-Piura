import 'package:flutter/material.dart';

/// {@template campo_comentario_input}
/// Widget reutilizable que proporciona el campo de entrada de texto y el botón
/// para enviar un nuevo comentario en la pantalla de detalle del reporte.
///
/// Muestra un indicador de carga mientras se envía el comentario ([isPosting]).
/// {@endtemplate}
class CampoComentarioInput extends StatelessWidget {
  /// Controlador para el campo de texto del comentario.
  final TextEditingController controller;
  /// Indica si el comentario se está enviando actualmente.
  final bool isPosting;
  /// Callback que se ejecuta al presionar el botón de enviar.
  final VoidCallback onSend;

  /// {@macro campo_comentario_input}
  const CampoComentarioInput({
    super.key,
    required this.controller,
    required this.isPosting,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          // Sombra sutil en la parte superior.
          BoxShadow(blurRadius: 5, color: Colors.black.withAlpha(26)),
        ],
      ),
      // SafeArea para evitar que el teclado obstruya la entrada en algunos dispositivos.
      child: SafeArea(
        child: Row(
          children: [
            /// Campo de texto principal.
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                    hintText: 'Escribe un comentario...',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 8)),
                enabled: !isPosting, // Deshabilitado mientras se envía.
                maxLines: null, // Permite múltiples líneas.
              ),
            ),
            /// Muestra un spinner o el botón de enviar.
            isPosting
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator()))
                : IconButton(
                    icon: Icon(Icons.send,
                        color: Theme.of(context).colorScheme.primary),
                    onPressed: onSend),
          ],
        ),
      ),
    );
  }
}

/// {@template prompt_login_comentario}
/// Widget que se muestra en lugar del campo de comentario cuando el usuario
/// no está autenticado.
///
/// Contiene un botón que redirige a la pantalla de login.
/// {@endtemplate}
class PromptLoginComentario extends StatelessWidget {
  /// {@macro prompt_login_comentario}
  const PromptLoginComentario({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
      width: double.infinity,
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
                blurRadius: 4,
                color: Colors.black.withAlpha(26),
                offset: const Offset(0, -2))
          ]),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.login),
        label: const Text('Inicia sesión para comentar'),
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12)),
        onPressed: () => Navigator.pushNamed(context, '/login'),
      ),
    );
  }
}