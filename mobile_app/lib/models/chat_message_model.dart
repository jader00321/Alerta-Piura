// lib/models/chat_message_model.dart
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
    // Determina la clave correcta para el timestamp (prefiere ISO)
    String timestampString = json['fecha_envio_iso'] // Enviado por el backend al guardar
                       ?? json['timestamp']       // Enviado por el backend al cargar historial
                       ?? DateTime.now().toIso8601String(); // Fallback muy improbable

    DateTime parsedTimestamp;
    try {
      // Parsea la fecha ISO 8601
      parsedTimestamp = DateTime.parse(timestampString).toLocal(); // Convierte a local
    } catch (e) {
      print("Error parseando chat timestamp: $timestampString. Usando hora actual.");
      parsedTimestamp = DateTime.now();
    }

    return ChatMessage(
      id: (json['id'] as num?)?.toInt() ?? 0, // Manejo seguro de ID
      // --- CLAVES CORREGIDAS ---
      idSender: (json['id_remitente'] as num?)?.toInt() ?? 0, // Clave del backend
      messageText: json['mensaje'] as String? ?? '',       // Clave del backend
      senderAlias: json['remitente_alias'] as String? ?? 'Usuario', // Clave del backend
      timestamp: parsedTimestamp,
    );
  }
}