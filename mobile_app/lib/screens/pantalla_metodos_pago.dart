import 'package:flutter/material.dart';
import 'package:mobile_app/api/metodo_pago_service.dart';
import 'package:mobile_app/models/metodo_pago_model.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_lista_notificaciones.dart';

/// {@template pantalla_metodos_pago}
/// Pantalla que permite al usuario ver y gestionar sus métodos de pago guardados.
///
/// Muestra una lista de las tarjetas asociadas a la cuenta.
/// Permite establecer una como predeterminada, eliminar tarjetas existentes
/// y navegar a [PantallaAgregarMetodoPago] para añadir una nueva.
/// {@endtemplate}
class PantallaMetodosPago extends StatefulWidget {
  /// {@macro pantalla_metodos_pago}
  const PantallaMetodosPago({super.key});
  @override
  State<PantallaMetodosPago> createState() => _PantallaMetodosPagoState();
}

/// Estado para [PantallaMetodosPago].
///
/// Maneja la carga y actualización de la lista de [MetodoPago],
/// así como las acciones de establecer predeterminado y eliminar.
class _PantallaMetodosPagoState extends State<PantallaMetodosPago> {
  /// Futuro que contiene la lista de métodos de pago.
  late Future<List<MetodoPago>> _metodosFuture;
  final MetodoPagoService _service = MetodoPagoService();

  @override
  void initState() {
    super.initState();
    _loadMetodos();
  }

  /// Carga o recarga la lista de métodos de pago desde [MetodoPagoService].
  void _loadMetodos() {
    setState(() {
      _metodosFuture = _service.listarMetodos();
    });
  }

  /// Llama a [MetodoPagoService.establecerPredeterminado] y recarga la lista.
  Future<void> _handleSetDefault(int id) async {
    final success = await _service.establecerPredeterminado(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? 'Método predeterminado actualizado.'
            : 'Error al actualizar.'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
      if (success) {
        _loadMetodos();
      }
    }
  }

  /// Muestra un diálogo de confirmación y llama a [MetodoPagoService.eliminarMetodo].
  ///
  /// Recarga la lista si la eliminación es exitosa. Muestra mensajes de error
  /// específicos si la API los devuelve (ej. no se puede eliminar el último método).
  Future<void> _handleDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Método de Pago'),
        content: const Text(
            '¿Estás seguro de que quieres eliminar esta tarjeta?'),
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
      final response = await _service.eliminarMetodo(id);
      if (mounted) {
        final success = response['statusCode'] == 200;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['message'] ??
              (success ? 'Tarjeta eliminada.' : 'Error al eliminar.')),
          backgroundColor: success ? Colors.green : Colors.red,
        ));
        if (success) {
          _loadMetodos();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Métodos de Pago')),
      body: FutureBuilder<List<MetodoPago>>(
        future: _metodosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const EsqueletoListaNotificaciones();
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error al cargar métodos: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'No tienes métodos de pago guardados.\nAñade uno para facilitar tus suscripciones.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          final metodos = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: metodos.length,
            itemBuilder: (context, index) {
              final metodo = metodos[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                child: ListTile(
                  leading: const Icon(Icons.credit_card, size: 36),
                  title: Text(
                      '${metodo.tipoTarjeta} terminada en ${metodo.ultimosCuatroDigitos}'),
                  subtitle: Text('Expira: ${metodo.fechaExpiracion}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (metodo.esPredeterminado)
                        Chip(
                          label: const Text('Predet.'),
                          backgroundColor: Colors.teal.shade100,
                          labelStyle: TextStyle(color: Colors.teal.shade900),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'default') {
                            _handleSetDefault(metodo.id);
                          }
                          if (value == 'delete') {
                            _handleDelete(metodo.id);
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          if (!metodo.esPredeterminado)
                            const PopupMenuItem<String>(
                              value: 'default',
                              child: Text('Establecer como predeterminado'),
                            ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Eliminar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navega a la pantalla para añadir tarjeta y espera un resultado.
          final result =
              await Navigator.pushNamed(context, '/agregar_metodo_pago');
          // Si el resultado es true, refresca la lista.
          if (result == true) {
            _loadMetodos();
          }
        },
        label: const Text('Añadir Tarjeta'),
        icon: const Icon(Icons.add_card),
      ),
    );
  }
}