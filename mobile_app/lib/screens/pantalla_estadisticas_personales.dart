import 'package:flutter/material.dart';
import 'package:mobile_app/api/perfil_service.dart';
import 'package:mobile_app/models/estadisticas_model.dart';
// Importamos los nuevos widgets
import 'package:mobile_app/widgets/estadisticas/tarjeta_resumen_actividad.dart';
import 'package:mobile_app/widgets/estadisticas/tarjeta_tendencia_mensual.dart'; // Nuevo gráfico de línea
import 'package:mobile_app/widgets/estadisticas/tarjeta_grafico_categorias.dart';
import 'package:mobile_app/widgets/estadisticas/tabla_estado_reportes.dart';

class PantallaEstadisticasPersonales extends StatefulWidget {
  const PantallaEstadisticasPersonales({super.key});

  @override
  State<PantallaEstadisticasPersonales> createState() =>
      _PantallaEstadisticasPersonalesState();
}

class _PantallaEstadisticasPersonalesState
    extends State<PantallaEstadisticasPersonales> {
  final PerfilService _perfilService = PerfilService();
  
  // Futuro que contendrá ahora 4 resultados
  late Future<List<dynamic>> _datosFuture;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    setState(() {
      // Pedimos los 4 endpoints en paralelo
      _datosFuture = Future.wait([
        _perfilService.getMisEstadisticasResumen(),  // Index 0: Resumen total
        _perfilService.getMisReportesPorMes(),       // Index 1: Tendencia mensual
        _perfilService.getMisReportesPorCategoria(), // Index 2: Categorías
        _perfilService.getMisReportesPorEstado(),    // Index 3: Estados
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Estadísticas'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar datos',
            onPressed: _cargarDatos,
          )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _datosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'No se pudieron cargar las estadísticas.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _cargarDatos,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    )
                  ],
                ),
              ),
            );
          }

          // Desempaquetamos los resultados
          final resumen = snapshot.data![0] as EstadisticasResumen;
          final mensual = snapshot.data![1] as List<DatoGrafico>;
          final categorias = snapshot.data![2] as List<DatoGrafico>;
          final estados = snapshot.data![3] as List<DatoGrafico>;

          // Validación si no hay actividad alguna
          if (resumen.totalReportes == 0 && resumen.totalApoyos == 0 && resumen.totalComentarios == 0) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.insights, size: 80, color: Colors.grey.shade300),
                   const SizedBox(height: 24),
                   const Text(
                     "Aún no tienes actividad registrada.",
                     style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold),
                   ),
                   const SizedBox(height: 8),
                   const Text(
                     "Tus estadísticas aparecerán aquí cuando\ncomiences a interactuar con la plataforma.",
                     textAlign: TextAlign.center,
                     style: TextStyle(color: Colors.grey),
                   ),
                 ],
               ),
             );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. NUEVO: Tarjetas de Resumen Inicial
                TarjetaResumenActividad(resumen: resumen),
                const SizedBox(height: 32),

                // 2. NUEVO: Gráfico de Línea (Tendencia)
                TarjetaTendenciaMensual(datos: mensual),
                const SizedBox(height: 24),

                // 3. ACTUALIZADO: Gráfico de Torta (Categorías)
                TarjetaGraficoCategorias(datos: categorias),
                const SizedBox(height: 24),

                // 4. ACTUALIZADO: Tabla de Efectividad (Estados)
                TablaEstadoReportes(datos: estados),
                
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}