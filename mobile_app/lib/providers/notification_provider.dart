import 'package:flutter/material.dart';
import 'package:mobile_app/api/perfil_service.dart';
import 'package:mobile_app/models/notificacion_model.dart';

/// Gestiona el estado global de las notificaciones (contador no leído y lista actual).
class NotificationProvider with ChangeNotifier {
  final PerfilService _service = PerfilService();
  
  // Estado del contador (Badge)
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  // Estado de la lista (Bandeja de entrada)
  List<Notificacion> _notificaciones = [];
  List<Notificacion> get notificaciones => _notificaciones;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Filtros actuales
  String _currentFilter = 'all'; // 'all', 'unread', 'archived'
  String? _currentCategory;
  String? _currentSearch;

  /// Carga inicial del contador (ej. al abrir la app).
  Future<void> loadUnreadCount() async {
    try {
      _unreadCount = await _service.getConteoNoLeidas();
      notifyListeners();
    } catch (e) {
      debugPrint('Error cargando conteo notificaciones: $e');
    }
  }

  /// Carga la lista completa con los filtros actuales.
  Future<void> loadNotifications({bool refresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final results = await _service.getNotificacionesAvanzadas(
        filter: _currentFilter,
        category: _currentCategory,
        search: _currentSearch,
        page: 1, // Simplificado para carga única (se puede añadir paginación después)
      );
      _notificaciones = results;
      
      // Si estamos viendo la bandeja principal, actualizamos el contador real
      if (_currentFilter != 'archived') {
         loadUnreadCount();
      }
    } catch (e) {
      debugPrint('Error cargando lista de notificaciones: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Acciones de Usuario ---

  /// Aplica filtros y recarga la lista.
  void setFilters({String? filter, String? category, String? search}) {
    if (filter != null) _currentFilter = filter;
    if (category != null) _currentCategory = category == 'Todas' ? null : category;
    if (search != null) _currentSearch = search;
    
    loadNotifications(refresh: true);
  }

  /// Marca una notificación como leída (Visualmente instantáneo).
  Future<void> markAsRead(int id) async {
    final index = _notificaciones.indexWhere((n) => n.id == id);
    if (index != -1 && !_notificaciones[index].leido) {
      // Actualización optimista
      _notificaciones[index].leido = true;
      _unreadCount = (_unreadCount - 1).clamp(0, 999);
      notifyListeners();
      
      // Llamada a API silenciosa
      await _service.marcarLeida(id);
    }
  }

  /// Marca TODAS las notificaciones visibles como leídas.
  Future<bool> markAllAsRead() async {
    try {
      // Actualización optimista local
      for (var n in _notificaciones) {
        n.leido = true;
      }
      _unreadCount = 0;
      notifyListeners();

      // Llamada a API
      final success = await _service.marcarTodasComoLeidas();
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Archiva/Desarchiva una notificación.
  Future<void> archiveNotification(Notificacion notif) async {
    // La quitamos de la lista actual inmediatamente
    _notificaciones.removeWhere((n) => n.id == notif.id);
    notifyListeners();
    
    // Llamada a API
    await _service.toggleArchivar(notif.id, !notif.archivado);
  }

  /// Elimina definitivamente.
  Future<void> deleteNotification(int id) async {
    _notificaciones.removeWhere((n) => n.id == id);
    notifyListeners();
    await _service.eliminarNotificaciones([id]);
  }

  /// Elimina múltiples notificaciones.
  Future<void> deleteMultiple(List<int> ids) async {
    _notificaciones.removeWhere((n) => ids.contains(n.id));
    notifyListeners();
    await _service.eliminarNotificaciones(ids);
  }
}