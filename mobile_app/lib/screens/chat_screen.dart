import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:mobile_app/models/chat_message_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/services/socket_service.dart';
import 'package:provider/provider.dart';

/// {@template chat_screen}
/// Pantalla que muestra la interfaz de chat en tiempo real para un reporte específico.
///
/// Permite a los usuarios (generalmente el autor y un líder) ver el historial 
/// de mensajes y enviar nuevos mensajes a través de [SocketService].
/// {@endtemplate}
class ChatScreen extends StatefulWidget {
  /// El ID del reporte al cual está vinculado este chat.
  final int reporteId;

  /// El título del reporte, para mostrarse en la [AppBar].
  final String reporteTitulo;

  /// {@macro chat_screen}
  const ChatScreen(
      {super.key, required this.reporteId, required this.reporteTitulo});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

/// Estado para [ChatScreen].
///
/// Maneja la carga del historial de mensajes, la conexión al socket,
/// el envío de nuevos mensajes y la lista de [ChatMessage].
class _ChatScreenState extends State<ChatScreen> {
  final ReporteService _reporteService = ReporteService();
  final SocketService _socketService = SocketService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// Lista de mensajes mostrados en el chat.
  List<ChatMessage> _messages = [];
  /// Indica si se está cargando el historial de mensajes.
  bool _isLoading = true;
  /// El ID del usuario actualmente autenticado.
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = Provider.of<AuthNotifier>(context, listen: false).userId;
    _loadHistoryAndConnect();
  }

  /// Carga el historial de chat desde la API y luego se conecta al socket.
  Future<void> _loadHistoryAndConnect() async {
    try {
      final history = await _reporteService.getChatHistory(widget.reporteId);
      if (mounted) {
        setState(() {
          _messages = history;
          _isLoading = false;
        });
        _scrollToBottom();
      }
      _connectToChat();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al cargar el historial del chat.')));
      }
    }
  }

  /// Se une a la sala de chat de Socket.IO y escucha nuevos mensajes.
  void _connectToChat() {
    _socketService.emit('join-chat-room', widget.reporteId.toString());
    _socketService.on('receive-message', (data) {
      if (mounted) {
        final newMessage = ChatMessage.fromJson(data);
        setState(() {
          _messages.add(newMessage);
        });
        _scrollToBottom();
      }
    });
  }

  /// Envía el mensaje del [TextEditingController] a través de [SocketService].
  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _currentUserId == null) {
      return;
    }

    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final senderAlias = authNotifier.userAlias ?? 'Usuario';

    _socketService.emit('send-message', {
      'id_reporte': widget.reporteId,
      'id_sender': _currentUserId,
      'message_text': text,
      'sender_alias': senderAlias,
    });
    _messageController.clear();
  }

  /// Desplaza el [ListView] al final para mostrar el último mensaje.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _socketService.emit('leave-room', widget.reporteId.toString());
    _socketService.off('receive-message');
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat: ${widget.reporteTitulo}',
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg.idSender == _currentUserId;
                      return _ChatMessageBubble(message: msg, isMe: isMe);
                    },
                  ),
          ),
          _ChatInput(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

/// {@template chat_message_bubble}
/// Widget para renderizar una única burbuja de chat.
///
/// Se alinea a la derecha si [isMe] es true.
/// {@endtemplate}
class _ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _ChatMessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isMe
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;
    final textColor =
        isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMe)
                CircleAvatar(
                  radius: 12,
                  child: Text(message.senderAlias[0]),
                ),
              if (!isMe) const SizedBox(width: 8),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft:
                          isMe ? const Radius.circular(18) : const Radius.circular(4),
                      bottomRight:
                          isMe ? const Radius.circular(4) : const Radius.circular(18),
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child:
                      Text(message.messageText, style: TextStyle(color: textColor)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 40, right: 8),
            child: Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          )
        ],
      ),
    );
  }
}

/// {@template chat_input}
/// Widget para la barra de entrada de texto en la parte inferior del chat.
/// {@endtemplate}
class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _ChatInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 4,
            color: Colors.black.withAlpha(13),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              icon: const Icon(Icons.send),
              onPressed: onSend,
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}