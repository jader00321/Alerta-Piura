import 'package:mobile_app/models/analiticas_reportero_model.dart';
import 'package:mobile_app/models/estadisticas_model.dart';

/// Clase contenedora para todos los datos del dashboard analítico.
class AnaliticasDashboardData {
  final List<DatoGrafico> porCategoria;
  final List<DatoGrafico> porDistrito;
  final List<DatoGrafico> tendencia;
  final List<DatoGrafico> porUrgencia;
  final TiemposAtencion eficiencia;
  final List<PuntoMapaCalor> mapaCalor;

  AnaliticasDashboardData({
    required this.porCategoria,
    required this.porDistrito,
    required this.tendencia,
    required this.porUrgencia,
    required this.eficiencia,
    required this.mapaCalor,
  });
}