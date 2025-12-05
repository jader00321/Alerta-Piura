import 'package:flutter/material.dart';
import 'package:mobile_app/models/notificacion_model.dart';
import 'package:mobile_app/providers/notification_provider.dart';
import 'package:mobile_app/screens/detalle_notificacion_screen.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_lista_notificaciones.dart';
import 'package:mobile_app/widgets/notificaciones/notification_filter_bar.dart';
import 'package:mobile_app/widgets/notificaciones/notification_tile.dart';
import 'package:provider/provider.dart';

class PantallaAlertas extends StatefulWidget {
  const PantallaAlertas({super.key});

  @override
  State<PantallaAlertas> createState() => _PantallaAlertasState();
}

class _PantallaAlertasState extends State<PantallaAlertas> {
  final Set<int> _selectedIds = {};
  bool get _isSelectionMode => _selectedIds.isNotEmpty;
  String _activeFilter = 'all'; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications(refresh: true);
    });
  }

  // ... (Métodos de selección _toggleSelection, _clearSelection, _selectAll IGUALES que antes) ...
  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(() => _selectedIds.clear());
  }

  void _selectAll(List<Notificacion> notificaciones) {
    setState(() => _selectedIds.addAll(notificaciones.map((n) => n.id)));
  }

  // --- NUEVOS MÉTODOS CON DIÁLOGOS DE CONFIRMACIÓN ---

  Future<void> _confirmarEliminarSeleccionados(NotificationProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('¿Eliminar ${_selectedIds.length} notificaciones?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('Eliminar', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm == true) {
      await provider.deleteMultiple(_selectedIds.toList());
      _clearSelection();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Eliminadas correctamente')));
    }
  }

  Future<void> _confirmarMarcarTodoLeido(NotificationProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Marcar todo como leído?'),
        content: const Text('Todas las notificaciones visibles se marcarán como leídas.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmar')),
        ],
      ),
    );

    if (confirm == true) {
      await provider.markAllAsRead();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Todo marcado como leído')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final notificaciones = provider.notificaciones;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _isSelectionMode
          ? AppBar(
              backgroundColor: theme.colorScheme.primaryContainer,
              leading: IconButton(icon: const Icon(Icons.close), onPressed: _clearSelection),
              title: Text('${_selectedIds.length} seleccionadas'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: () => _selectAll(notificaciones),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _confirmarEliminarSeleccionados(provider),
                ),
              ],
            )
          : AppBar(
              title: const Text('Buzón de Alertas'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => provider.loadNotifications(refresh: true),
                ),
                // Menú de opciones
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'read_all') _confirmarMarcarTodoLeido(provider);
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'read_all', child: Text('Marcar todo como leído')),
                  ],
                )
              ],
            ),
      
      body: Column(
        children: [
          if (!_isSelectionMode)
            NotificationFilterBar(
              currentFilter: _activeFilter,
              onSearchChanged: (q) => provider.setFilters(search: q),
              onFilterChanged: (f) {
                setState(() { _activeFilter = f; _clearSelection(); });
                provider.setFilters(filter: f);
              },
            ),

          Expanded(
            child: provider.isLoading && notificaciones.isEmpty
                ? const EsqueletoListaNotificaciones()
                : notificaciones.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: notificaciones.length,
                        itemBuilder: (context, index) {
                          final notif = notificaciones[index];
                          final isSelected = _selectedIds.contains(notif.id);

                          return NotificationTile(
                            notificacion: notif,
                            isSelectionMode: _isSelectionMode,
                            isSelected: isSelected,
                            onTap: () {
                              if (_isSelectionMode) {
                                _toggleSelection(notif.id);
                              } else {
                                // Navegar y luego refrescar
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetalleNotificacionScreen(notificacion: notif),
                                  ),
                                ).then((_) => provider.loadNotifications()); // Refrescar al volver
                              }
                            },
                            onLongPress: () => _toggleSelection(notif.id),
                            // Swipe solo si no hay selección
                            onDismissed: _isSelectionMode ? null : (direction) {
                              if (direction == DismissDirection.startToEnd) {
                                provider.archiveNotification(notif);
                              } else {
                                provider.deleteNotification(notif.id);
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
      return const Center(child: Text("No tienes notificaciones.", style: TextStyle(color: Colors.grey)));
  }
}