import 'dart:convert'; // <--- NECESARIO PARA jsonEncode

/// Representa una notificación avanzada del sistema 2.0.
class Notificacion {
  final int id;
  final String titulo;
  final String cuerpo;
  bool leido; // Mutable para actualización optimista
  final DateTime fechaEnvio;
  
  // --- Nuevos Campos Fase 2 ---
  final String? payload; // Para navegación (Lo guardamos como String para compatibilidad)
  final bool archivado;
  final String categoria; 
  final Map<String, dynamic>? remitenteInfo; 

  Notificacion({
    required this.id,
    required this.titulo,
    required this.cuerpo,
    required this.leido,
    required this.fechaEnvio,
    this.payload,
    required this.archivado,
    required this.categoria,
    this.remitenteInfo,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    // Lógica de seguridad para el payload
    String? safePayload;
    if (json['payload'] != null) {
      if (json['payload'] is Map) {
        // Si viene como Objeto JSON, lo convertimos a String
        safePayload = jsonEncode(json['payload']);
      } else if (json['payload'] is String) {
        // Si ya viene como String, lo usamos directo
        safePayload = json['payload'];
      }
    }

    return Notificacion(
      id: json['id'],
      titulo: json['titulo'],
      cuerpo: json['cuerpo'],
      leido: json['leido'] ?? false,
      fechaEnvio: DateTime.parse(json['fecha_envio']),
      payload: safePayload, // Usamos la variable procesada
      archivado: json['archivado'] ?? false,
      categoria: json['categoria'] ?? 'General',
      remitenteInfo: json['remitente_info'],
    );
  }
}