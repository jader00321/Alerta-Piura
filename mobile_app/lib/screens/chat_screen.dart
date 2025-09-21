import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:mobile_app/models/chat_message_model.dart';
import 'package:mobile_app/services/socket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  final int reporteId;
  final String reporteTitulo;
  const ChatScreen({super.key, required this.reporteId, required this.reporteTitulo});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ReporteService _reporteService = ReporteService();
  final SocketService _socketService = SocketService();
  final TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _messages = [];
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _connectToChat();
  }

  void _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token != null) {
      final decodedToken = JwtDecoder.decode(token);
      _currentUserId = decodedToken['user']['id'];
    }
    final history = await _reporteService.getChatHistory(widget.reporteId);
    setState(() {
      _messages = history;
    });
  }

  void _connectToChat() {
    _socketService.connect();
    _socketService.emit('join-chat-room', widget.reporteId.toString());
    _socketService.on('receive-message', (data) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage.fromJson(data));
        });
      }
    });
  }

  @override
  void dispose() {
    _socketService.disconnect();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentUserId == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) return;
    final decodedToken = JwtDecoder.decode(token);
    final senderAlias = decodedToken['user']['alias'] ?? decodedToken['user']['nombre'];

    _socketService.emit('send-message', {
      'id_reporte': widget.reporteId,
      'id_sender': _currentUserId,
      'message_text': _messageController.text.trim(),
      'sender_alias': senderAlias,
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.reporteTitulo)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg.idSender == _currentUserId;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Card(
                    color: isMe ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.secondaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(msg.messageText),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: 'Escribe un mensaje...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}