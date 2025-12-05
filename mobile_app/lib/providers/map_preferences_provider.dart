import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/models/ubicacion_guardada_model.dart';

/// Gestiona las preferencias de ubicación del mapa.
///
/// Permite guardar ubicaciones favoritas, seleccionar una como predeterminada
/// y restaurar la ubicación por defecto del sistema.
/// Notifica a los listeners (UI) cuando ocurre cualquier cambio.
class MapPreferencesProvider with ChangeNotifier {
  static const String _kSavedLocationsKey = 'saved_locations_list';
  static const String _kDefaultLocationIdKey = 'default_location_id_v2';
  
  // Ubicación "hardcoded" del sistema (Piura Centro).
  static const LatLng sistemaDefaultLocation = LatLng(-5.19449, -80.63282);

  List<UbicacionGuardada> _ubicacionesGuardadas = [];
  String? _defaultLocationId; // Si es null, se usa la del sistema.

  /// Retorna la lista de ubicaciones guardadas.
  List<UbicacionGuardada> get ubicaciones => List.unmodifiable(_ubicacionesGuardadas);

  /// Retorna el ID de la ubicación seleccionada como default (o null).
  String? get defaultLocationId => _defaultLocationId;

  /// Retorna la coordenada [LatLng] activa que debe usar el mapa al iniciar.
  LatLng get activeLocation {
    if (_defaultLocationId == null) return sistemaDefaultLocation;
    
    try {
      final selected = _ubicacionesGuardadas.firstWhere((u) => u.id == _defaultLocationId);
      return selected.toLatLng();
    } catch (e) {
      // Si la ubicación guardada ya no existe (error de integridad), volver a default.
      return sistemaDefaultLocation;
    }
  }

  /// Carga las preferencias desde el almacenamiento local.
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Cargar lista de ubicaciones
    final String? listJson = prefs.getString(_kSavedLocationsKey);
    if (listJson != null) {
      final List<dynamic> decoded = json.decode(listJson);
      _ubicacionesGuardadas = decoded.map((item) => UbicacionGuardada.fromJson(item)).toList();
      // Ordenar: más recientes primero
      _ubicacionesGuardadas.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
    }

    // 2. Cargar selección por defecto
    _defaultLocationId = prefs.getString(_kDefaultLocationIdKey);
    
    notifyListeners();
  }

  /// Guarda una nueva ubicación en la lista.
  ///
  /// [nombre]: Nombre personalizado dado por el usuario.
  /// [lat], [lng]: Coordenadas.
  /// [setAsDefault]: Si es true, la establece inmediatamente como predeterminada.
  Future<void> addLocation(String nombre, double lat, double lng, {bool setAsDefault = false}) async {
    final nuevaUbicacion = UbicacionGuardada(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombre,
      lat: lat,
      lng: lng,
      fechaCreacion: DateTime.now(),
    );

    _ubicacionesGuardadas.insert(0, nuevaUbicacion); // Agregar al inicio
    await _saveListToDisk();

    if (setAsDefault) {
      await setDefaultLocation(nuevaUbicacion.id);
    } else {
      notifyListeners();
    }
  }

  /// Elimina una ubicación de la lista.
  ///
  /// Si la ubicación eliminada era la predeterminada, restaura el default del sistema.
  Future<void> removeLocation(String id) async {
    _ubicacionesGuardadas.removeWhere((u) => u.id == id);
    await _saveListToDisk();

    if (_defaultLocationId == id) {
      await restoreSystemDefault();
    } else {
      notifyListeners();
    }
  }

  /// Establece una ubicación guardada como la predeterminada.
  Future<void> setDefaultLocation(String id) async {
    _defaultLocationId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDefaultLocationIdKey, id);
    notifyListeners();
  }

  /// Restaura la configuración para usar la ubicación por defecto del sistema.
  Future<void> restoreSystemDefault() async {
    _defaultLocationId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kDefaultLocationIdKey);
    notifyListeners();
  }

  /// Método privado para persistir la lista completa en disco.
  Future<void> _saveListToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_ubicacionesGuardadas.map((u) => u.toJson()).toList());
    await prefs.setString(_kSavedLocationsKey, encoded);
  }
}