// lib/models/reporte_cercano_model.dart

class ReporteCercano {
  final int id;
  final String titulo;
  final String categoria;
  final String estado;
  final String? fotoUrl;
  final int apoyosPendientes; // <-- Contador de TODOS los apoyos pendientes
  final double distanciaMetros;
  final int idUsuario;
  final String autor;
  final String fechaCreacionFormateada;
  final bool esPrioritario;
  final String? urgencia;
  final bool puedeUnirse;
  // --- NUEVO CAMPO ---
  final bool usuarioActualUnido; // <-- Flag: ¿El usuario actual ya se unió?

  ReporteCercano({
    required this.id,
    required this.titulo,
    required this.categoria,
    required this.estado,
    this.fotoUrl,
    required this.apoyosPendientes,
    required this.distanciaMetros,
    required this.idUsuario,
    required this.autor,
    required this.fechaCreacionFormateada,
    required this.esPrioritario,
    this.urgencia,
    required this.puedeUnirse,
    // --- NUEVO CAMPO ---
    required this.usuarioActualUnido,
  });

  factory ReporteCercano.fromJson(Map<String, dynamic> json) {
    return ReporteCercano(
      id: json['id'],
      titulo: json['titulo'],
      categoria: json['categoria'],
      estado: json['estado'],
      fotoUrl: json['foto_url'],
      apoyosPendientes: (json['apoyos_pendientes'] as num?)?.toInt() ?? 0,
      distanciaMetros: (json['distancia_metros'] as num).toDouble(),
      idUsuario: json['id_usuario'],
      autor: json['autor'],
      fechaCreacionFormateada: json['fecha_creacion_formateada'],
      esPrioritario: json['es_prioritario'] ?? false,
      urgencia: json['urgencia'],
      puedeUnirse: json['puede_unirse'] ?? false,
      // --- NUEVO CAMPO ---
      usuarioActualUnido: json['usuario_actual_unido'] ?? false,
    );
  }
}
