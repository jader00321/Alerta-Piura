import 'package:flutter/material.dart';
import 'package:mobile_app/api/perfil_service.dart';
import 'package:mobile_app/models/zona_segura_model.dart';
import 'package:mobile_app/widgets/alertas_personalizadas/tarjeta_zona_segura.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_lista_reportes.dart';

/// {@template pantalla_alertas_personalizadas}
/// Pantalla para gestionar las "Zonas Seguras" del usuario (función Premium).
///
/// Muestra una lista de [TarjetaZonaSegura] y permite navegar a
/// [PantallaCrearZona] para añadir nuevas zonas o eliminarlas.
/// {@endtemplate}
class PantallaAlertasPersonalizadas extends StatefulWidget {
  /// {@macro pantalla_alertas_personalizadas}
  const PantallaAlertasPersonalizadas({super.key});

  @override
  State<PantallaAlertasPersonalizadas> createState() =>
      _PantallaAlertasPersonalizadasState();
}

/// Estado para [PantallaAlertasPersonalizadas].
class _PantallaAlertasPersonalizadasState
    extends State<PantallaAlertasPersonalizadas> {
  /// Futuro que contiene la lista de zonas seguras del usuario.
  late Future<List<ZonaSegura>> _zonasFuture;
  final PerfilService _perfilService = PerfilService();

  @override
  void initState() {
    super.initState();
    _cargarZonas();
  }

  /// Carga o recarga la lista de [ZonaSegura] desde [PerfilService].
  void _cargarZonas() {
    setState(() {
      _zonasFuture = _perfilService.getMisZonasSeguras();
    });
  }

  /// Muestra un diálogo de confirmación y elimina una [ZonaSegura] por su [idZona].
  Future<void> _eliminarZona(int idZona) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Zona Segura'),
        content: const Text(
            '¿Estás seguro de que quieres eliminar esta zona? Dejarás de recibir alertas para esta área.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _perfilService.eliminarZonaSegura(idZona);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                success ? 'Zona eliminada.' : 'Error al eliminar la zona.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          _cargarZonas();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas de Zonas Seguras'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _cargarZonas(),
        child: FutureBuilder<List<ZonaSegura>>(
          future: _zonasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const EsqueletoListaReportes();
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text('Error al cargar las zonas: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'Aún no has creado ninguna zona segura. ¡Añade una para empezar a recibir alertas!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              );
            }

            final zonas = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: zonas.length,
              itemBuilder: (context, index) {
                final zona = zonas[index];
                return TarjetaZonaSegura(
                  nombreZona: zona.nombre,
                  centro: zona.centro,
                  radio: zona.radioMetros.toDouble(),
                  onDelete: () => _eliminarZona(zona.id),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result =
              await Navigator.pushNamed(context, '/crear_zona_segura');
          if (result == true) {
            _cargarZonas();
          }
        },
        label: const Text('Añadir Zona'),
        icon: const Icon(Icons.add_location_alt_outlined),
      ),
    );
  }
}