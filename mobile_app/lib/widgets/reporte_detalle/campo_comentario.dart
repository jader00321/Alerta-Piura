import 'package:flutter/material.dart';

class CampoComentarioInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isPosting;
  final VoidCallback onSend;

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
          BoxShadow(
              blurRadius: 5, color: Colors.black.withAlpha(26)), // CORREGIDO
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                    hintText: 'Escribe un comentario...',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 8)),
                enabled: !isPosting,
                maxLines: null,
              ),
            ),
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

class PromptLoginComentario extends StatelessWidget {
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
          ] // CORREGIDO
          ),
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
