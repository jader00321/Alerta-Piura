import 'package:flutter/foundation.dart';

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
    String timestampString = json['fecha_envio_iso'] ??
        json['timestamp'] ??
        DateTime.now().toIso8601String();

    DateTime parsedTimestamp;
    try {
      parsedTimestamp = DateTime.parse(timestampString).toLocal();
    } catch (e) {
      debugPrint(
          "Error parseando chat timestamp: $timestampString. Usando hora actual.");
      parsedTimestamp = DateTime.now();
    }

    return ChatMessage(
      id: (json['id'] as num?)?.toInt() ?? 0,
      idSender: (json['id_remitente'] as num?)?.toInt() ?? 0,
      messageText: json['mensaje'] as String? ?? '',
      senderAlias: json['remitente_alias'] as String? ?? 'Usuario',
      timestamp: parsedTimestamp,
    );
  }
}
