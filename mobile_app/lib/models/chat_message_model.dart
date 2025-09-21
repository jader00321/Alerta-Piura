class ChatMessage {
  final int id;
  final int idSender;
  final String messageText;
  final String senderAlias;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.idSender,
    required this.messageText,
    required this.senderAlias,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      idSender: json['id_sender'],
      messageText: json['message_text'],
      senderAlias: json['sender_alias'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}