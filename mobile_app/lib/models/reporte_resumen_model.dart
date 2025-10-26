// lib/models/reporte_resumen_model.dart

class ReporteResumen {
  final int id;
  final String titulo;
  final String estado;
  final String? fecha;
  final String? fotoUrl;
  final String? categoria;
  final String? autor; // Se mantiene por si se usa en otras pestañas
  final bool esPrioritario;
  final String? miComentario;
  // --- CAMPOS NUEVOS ---
  final String? urgencia;
  final String? distrito;

  ReporteResumen({
    required this.id,
    required this.titulo,
    required this.estado,
    this.fecha,
    this.fotoUrl,
    this.categoria,
    this.autor,
    required this.esPrioritario,
    this.miComentario,
    // --- AÑADIDOS AL CONSTRUCTOR ---
    this.urgencia,
    this.distrito,
  });

  factory ReporteResumen.fromJson(Map<String, dynamic> json) {
    return ReporteResumen(
      id: json['id'],
      titulo: json['titulo'] ?? 'Sin Título', // Fallback
      estado: json['estado'] ?? 'desconocido', // Fallback
      fecha: json['fecha'],
      fotoUrl: json['foto_url'],
      categoria: json['categoria'],
      autor: json[
          'autor'], // Aunque no se use en "Mis Reportes", mantener por consistencia
      esPrioritario: json['es_prioritario'] ?? false,
      miComentario: json['mi_comentario'],
      // --- PARSEAR NUEVOS CAMPOS ---
      urgencia: json['urgencia'],
      distrito: json['distrito'],
    );
  }
}
