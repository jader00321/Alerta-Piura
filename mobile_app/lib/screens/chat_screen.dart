import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:mobile_app/models/chat_message_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/services/socket_service.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final int reporteId;
  final String reporteTitulo;
  
  /// Controla si mostrar el botón de "Ver Reporte".
  /// Si venimos del detalle (true), no mostramos el botón para evitar un ciclo infinito.
  final bool fromReportDetails;

  const ChatScreen({
    super.key, 
    required this.reporteId, 
    required this.reporteTitulo,
    this.fromReportDetails = false, // Por defecto asumimos que viene de la lista de chats
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ReporteService _reporteService = ReporteService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Referencia al listener para poder limpiarlo correctamente
  late final Function(dynamic) _receiveHandler; 

  List<ChatMessage> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Definimos el handler aquí para tener una referencia estable
    _receiveHandler = _handleReceiveMessage;
    _loadMessages();
  }

  @override
  void dispose() {
    // Importante: Limpiar el listener y salir de la sala al cerrar la pantalla
    SocketService().off('receive-message', _receiveHandler); 
    SocketService().emit('leaveRoom', 'report_${widget.reporteId}');
    
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _markMessagesAsRead() {
    _reporteService.markChatAsRead(widget.reporteId);
  }

  Future<void> _loadMessages() async {
    try {
      // 1. Cargar historial previo (REST API)
      final history = await _reporteService.getChatHistory(widget.reporteId);
      
      // 2. Conectarse a la sala en tiempo real (Socket)
      final room = 'report_${widget.reporteId}';
      SocketService().emit('joinRoom', room); 
      SocketService().on('receive-message', _receiveHandler);
      
      // 3. Marcar como leídos
      _markMessagesAsRead(); 

      if (mounted) {
        setState(() {
          _messages = history;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error de conexión. Revisa tu internet.')));
      }
    }
  }

  // --- ESTA FUNCIÓN HACE QUE EL MENSAJE APAREZCA AL INSTANTE ---
  void _handleReceiveMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Verificamos que el mensaje sea para ESTE reporte específico
      if (data['id_reporte'].toString() == widget.reporteId.toString()) {
        
        final message = ChatMessage.fromJson(data);
        
        if (mounted) {
          setState(() {
            _messages.add(message); // Agrega el nuevo mensaje a la lista visual
          });
          _scrollToBottom(); // Baja el scroll para verlo
          _markMessagesAsRead(); // Lo marca como leído inmediatamente
        }
      }
    }
  }

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

  void _submitMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final messageText = _messageController.text.trim();
    
    final messageData = {
      'id_reporte': widget.reporteId,
      'mensaje': messageText,
      'id_remitente': authNotifier.userId, 
      'remitente_alias': authNotifier.userAlias,
      'es_admin': false, 
    };

    // Enviamos al servidor. NO lo agregamos localmente aquí.
    // Esperamos a que el servidor nos lo devuelva vía _handleReceiveMessage.
    // Esto evita duplicados.
    SocketService().emit('send-message', messageData);
    
    _messageController.clear(); 
  }
  
  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();
    final currentUserId = authNotifier.userId;
    
    Widget chatUi = ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        // Es mío si el ID del remitente coincide con mi usuario
        final isMine = message.idSender == currentUserId; 

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Align(
            alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
            child: BubbleMessage(
              message: message,
              isMine: isMine,
            ),
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.reporteTitulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Text('Soporte y Seguimiento', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          // Botón "Ver Reporte" (Solo si NO venimos desde el detalle)
          if (!widget.fromReportDetails)
            TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/reporte_detalle', arguments: widget.reporteId);
              },
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: const Text("Ver Reporte"),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            )
          else
             // Si venimos del detalle, mostramos un icono simple o nada
             const Padding(
               padding: EdgeInsets.only(right: 16.0),
               child: Icon(Icons.chat_bubble, color: Colors.grey),
             )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(child: chatUi),
                InputBar(
                  controller: _messageController,
                  onSend: _submitMessage,
                  isPosting: false, 
                ),
              ],
            ),
    );
  }
}

// --- WIDGETS AUXILIARES (Incrustados para simplicidad) ---

class BubbleMessage extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;

  const BubbleMessage({super.key, required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Colores: Primario para mí, Gris/Surface para el otro
    final bubbleColor = isMine 
        ? theme.colorScheme.primary 
        : theme.colorScheme.surfaceContainerHighest;
    final textColor = isMine 
        ? theme.colorScheme.onPrimary 
        : theme.colorScheme.onSurface;

    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: isMine ? const Radius.circular(16) : Radius.zero,
          bottomRight: isMine ? Radius.zero : const Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 2, offset: const Offset(0, 1))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end, // Hora siempre a la derecha dentro de la burbuja
        children: [
          Text(
            message.messageText,
            style: theme.textTheme.bodyMedium?.copyWith(color: textColor, height: 1.4),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('HH:mm').format(message.timestamp),
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isPosting;

  const InputBar({super.key, required this.controller, required this.onSend, required this.isPosting});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [BoxShadow(offset: const Offset(0, -2), blurRadius: 6, color: Colors.black.withAlpha(10))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: onSend,
              icon: const Icon(Icons.send_rounded),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}