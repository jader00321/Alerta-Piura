class Conversacion {
  final int idReporte;
  final String tituloReporte;
  final String? fotoUrl;
  final String codigoReporte;
  final String ultimoMensaje;
  final DateTime fechaUltimoMensaje;
  final int unreadCount;
  final bool ultimoEsAdmin; // Para saber si dice "Tú:" o "Soporte:"

  Conversacion({
    required this.idReporte,
    required this.tituloReporte,
    this.fotoUrl,
    required this.codigoReporte,
    required this.ultimoMensaje,
    required this.fechaUltimoMensaje,
    required this.unreadCount,
    required this.ultimoEsAdmin,
  });

  factory Conversacion.fromJson(Map<String, dynamic> json) {
    return Conversacion(
      idReporte: json['id_reporte'],
      tituloReporte: json['titulo_reporte'] ?? 'Sin título',
      fotoUrl: json['foto_url'],
      codigoReporte: json['codigo_reporte'] ?? '---',
      ultimoMensaje: json['ultimo_mensaje'] ?? '',
      fechaUltimoMensaje: DateTime.parse(json['fecha_ultimo_mensaje']).toLocal(),
      unreadCount: int.parse(json['unread_count'].toString()),
      ultimoEsAdmin: json['ultimo_es_admin'] ?? false,
    );
  }
}

// Modelo simple para la lista "Iniciar Chat"
class ReporteSinChat {
  final int id;
  final String titulo;
  final String estado;
  final String fecha;
  final String? fotoUrl;

  ReporteSinChat({required this.id, required this.titulo, required this.estado, required this.fecha, this.fotoUrl});

  factory ReporteSinChat.fromJson(Map<String, dynamic> json) {
    return ReporteSinChat(
      id: json['id'],
      titulo: json['titulo'],
      estado: json['estado'],
      fecha: json['fecha_creacion'],
      fotoUrl: json['foto_url'],
    );
  }
}