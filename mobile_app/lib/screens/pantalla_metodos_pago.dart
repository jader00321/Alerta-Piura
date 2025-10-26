// lib/screens/pantalla_metodos_pago.dart

import 'package:flutter/material.dart';
import 'package:mobile_app/api/metodo_pago_service.dart';
import 'package:mobile_app/models/metodo_pago_model.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_lista_notificaciones.dart'; // Reutilizamos un esqueleto

class PantallaMetodosPago extends StatefulWidget {
  const PantallaMetodosPago({super.key});
  @override
  State<PantallaMetodosPago> createState() => _PantallaMetodosPagoState();
}

class _PantallaMetodosPagoState extends State<PantallaMetodosPago> {
  late Future<List<MetodoPago>> _metodosFuture;
  final MetodoPagoService _service = MetodoPagoService();

  @override
  void initState() {
    super.initState();
    _loadMetodos();
  }

  void _loadMetodos() {
    setState(() {
      _metodosFuture = _service.listarMetodos();
    });
  }

  Future<void> _handleSetDefault(int id) async {
    final success = await _service.establecerPredeterminado(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? 'Método predeterminado actualizado.'
            : 'Error al actualizar.'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
      if (success) _loadMetodos();
    }
  }

  Future<void> _handleDelete(int id) async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Eliminar Tarjeta'),
              content: const Text(
                  '¿Estás seguro de que quieres eliminar este método de pago?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancelar')),
                TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Eliminar')),
              ],
            ));

    if (confirm == true) {
      // --- LÓGICA DE MANEJO DE ERRORES CORREGIDA ---
      final response = await _service.eliminarMetodo(id);
      if (mounted) {
        // Obtenemos el mensaje específico del servidor
        final message = response['message'] ?? 'Ocurrió un error desconocido.';
        final success = response['statusCode'] == 200;

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : Colors.red,
        ));

        if (success) _loadMetodos();
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
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No tienes métodos de pago guardados.'));
          }
          final metodos = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: metodos.length,
            itemBuilder: (context, index) {
              final metodo = metodos[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.credit_card),
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
                        ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'default') _handleSetDefault(metodo.id);
                          if (value == 'delete') _handleDelete(metodo.id);
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
          final result =
              await Navigator.pushNamed(context, '/agregar_metodo_pago');
          if (result == true) _loadMetodos();
        },
        label: const Text('Añadir Tarjeta'),
        icon: const Icon(Icons.add_card),
      ),
    );
  }
}
