// lib/models/chat_message_model.dart
import 'package:flutter/foundation.dart';

/// Representa un único mensaje dentro de un chat.
class ChatMessage {
  final int id;
  final int idSender;
  final String messageText;
  final String senderAlias;
  final DateTime timestamp;
  
  /// Indica si el mensaje fue enviado por el administrador/líder (true) o el usuario móvil (false).
  final bool esAdmin; 
  
  /// Indica si el mensaje ha sido leído por el receptor.
  final bool isRead; 

  ChatMessage({
    required this.id,
    required this.idSender,
    required this.messageText,
    required this.senderAlias,
    required this.timestamp,
    required this.esAdmin,
    required this.isRead,
  });

  /// Crea una instancia de [ChatMessage] a partir de un mapa JSON.
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    String timestampString = json['fecha_envio_iso'] ?? json['timestamp'] ?? '';

    DateTime parsedTimestamp;
    try {
      parsedTimestamp = DateTime.parse(timestampString).toLocal();
    } catch (e) {
      debugPrint("Error parseando chat timestamp: $timestampString. Usando hora actual.");
      parsedTimestamp = DateTime.now();
    }

    return ChatMessage(
      id: (json['id'] as num?)?.toInt() ?? 0,
      // CRÍTICO: Mapeamos el ID del remitente a la clave que el backend usa
      idSender: (json['id_remitente'] as num?)?.toInt() ?? 0, 
      // CRÍTICO: Mapeamos el texto del mensaje a la clave que el backend usa
      messageText: json['mensaje'] as String? ?? '', 
      senderAlias: json['remitente_alias'] as String? ?? 'Desconocido', 
      timestamp: parsedTimestamp,
      esAdmin: json['es_admin'] ?? false,
      isRead: json['leido'] ?? true, 
    );
  }
}