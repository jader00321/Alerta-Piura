import 'dart:async';
import 'package:flutter/material.dart';

class NotificationFilterBar extends StatefulWidget {
  final Function(String) onSearchChanged;
  final Function(String) onFilterChanged; // 'all', 'unread', 'archived'
  final String currentFilter;

  const NotificationFilterBar({
    super.key,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.currentFilter,
  });

  @override
  State<NotificationFilterBar> createState() => _NotificationFilterBarState();
}

class _NotificationFilterBarState extends State<NotificationFilterBar> {
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearchChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isArchivedMode = widget.currentFilter == 'archived';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Barra de Búsqueda
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: isArchivedMode ? 'Buscar en archivados' : 'Buscar en notificaciones',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              // Botón para limpiar búsqueda
              suffixIcon: _searchController.text.isNotEmpty 
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    })
                : null,
            ),
          ),
          const SizedBox(height: 12),
          
          // Chips de Filtro
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Todas',
                  isSelected: widget.currentFilter == 'all',
                  onTap: () => widget.onFilterChanged('all'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'No leídas',
                  isSelected: widget.currentFilter == 'unread',
                  onTap: () => widget.onFilterChanged('unread'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Archivadas',
                  isSelected: widget.currentFilter == 'archived',
                  onTap: () => widget.onFilterChanged('archived'),
                  icon: Icons.archive_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: isSelected ? theme.colorScheme.onPrimaryContainer : Colors.grey.shade700),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? theme.colorScheme.onPrimaryContainer : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}