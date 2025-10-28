/// Representa un único mensaje dentro de un chat.
///
/// Este modelo se utiliza para mostrar los mensajes en el historial
/// del chat de un reporte, identificando al remitente y la hora.
class ChatMessage {
  /// El ID único del mensaje en la base de datos.
  final int id;

  /// El ID del usuario que envió el mensaje.
  final int idSender;

  /// El contenido de texto del mensaje.
  final String messageText;

  /// El alias (apodo) del remitente, para ser mostrado en la UI.
  final String senderAlias;

  /// La fecha y hora en que se envió el mensaje, convertida a hora local.
  final DateTime timestamp;

  /// Crea una instancia de [ChatMessage].
  ChatMessage({
    required this.id,
    required this.idSender,
    required this.messageText,
    required this.senderAlias,
    required this.timestamp,
  });

  /// Crea una instancia de [ChatMessage] a partir de un mapa JSON.
  ///
  /// Este factory maneja la deserialización de la respuesta de la API
  /// y normaliza el campo de la fecha y hora.
  ///
  /// El `fromJson` es robusto y puede manejar diferentes claves para
  /// el timestamp (`fecha_envio_iso` o `timestamp`) y convierte
  /// la fecha UTC de la base de datos a la hora local del dispositivo.
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // Determina la clave correcta para el timestamp (prefiere ISO)
    String timestampString = json['fecha_envio_iso'] // Enviado por el backend al guardar
            ??
            json['timestamp'] // Enviado por el backend al cargar historial
            ??
            DateTime.now().toIso8601String(); // Fallback muy improbable

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
      idSender: (json['id_remitente'] as num?)?.toInt() ?? 0, // Clave del backend
      messageText: json['mensaje'] as String? ?? '', // Clave del backend
      senderAlias:
          json['remitente_alias'] as String? ?? 'Usuario', // Clave del backend
      timestamp: parsedTimestamp,
    );
  }
}