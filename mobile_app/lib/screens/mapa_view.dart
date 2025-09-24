import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:mobile_app/models/reporte_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/widgets/pulsing_pin.dart';
import 'package:mobile_app/widgets/riesgo_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapaView extends StatefulWidget {
  const MapaView({super.key});

  @override
  State<MapaView> createState() => _MapaViewState();
}

class _MapaViewState extends State<MapaView> with TickerProviderStateMixin {
  final LatLng _initialCenter = const LatLng(-5.19449, -80.63282);
  final ReporteService _reporteService = ReporteService();
  late Future<List<Reporte>> _reportesFuture;
  final MapController _mapController = MapController();
  Timer? _debounce;
  int _riesgoScore = 0;
  bool _isLoadingRisk = true;
  Timer? _sosHoldTimer;
  bool _isHoldingSos = false;
  bool _isSosActive = false;
  int _sosRemainingSeconds = 0;
  Timer? _countdownTimer;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _loadReportes();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    
    FlutterBackgroundService().on('update').listen((event) {
      if (!mounted) return;
      if (event != null && event.containsKey('sos_remaining_seconds')) {
        final remaining = event['sos_remaining_seconds'] as int;
        
        setState(() {
          _isSosActive = remaining > 0;
          _sosRemainingSeconds = remaining;
        });

        _countdownTimer?.cancel();
        if (remaining > 0) {
          _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (_sosRemainingSeconds > 1) {
              if (mounted) setState(() => _sosRemainingSeconds--);
            } else {
              if (mounted) setState(() => _isSosActive = false);
              timer.cancel();
            }
          });
        }
      }
    });
     FlutterBackgroundService().on('stopSos').listen((event) {
      if (mounted) {
        // 1. Stop the background service's timers
        FlutterBackgroundService().invoke('stopTracking');
        
        // 2. Update the UI
        setState(() {
          _isSosActive = false;
          _countdownTimer?.cancel();
        });
        
        // 3. Show a confirmation message
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Un administrador ha finalizado la alerta SOS.'),
          backgroundColor: Colors.blue,
        ));
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _sosHoldTimer?.cancel();
    _countdownTimer?.cancel();
    _glowController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _loadReportes() {
    setState(() {
      _reportesFuture = _reporteService.getAllReports();
    });
  }

  void _onSosPressStart(LongPressStartDetails details) {
    setState(() => _isHoldingSos = true);
    _sosHoldTimer = Timer(const Duration(seconds: 3), () async { 
      final prefs = await SharedPreferences.getInstance();
      final durationInMinutes = prefs.getDouble('sosDuration') ?? 10.0;
      
      // Pass the duration to the background service
      FlutterBackgroundService().invoke('startSosTracking', {
        'durationInSeconds': durationInMinutes.toInt() * 60,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Alerta SOS activada. Transmitiendo ubicación.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
      setState(() => _isHoldingSos = false);
    });
  }

  void _onSosPressEnd(LongPressEndDetails details) {
    _sosHoldTimer?.cancel();
    setState(() => _isHoldingSos = false);
  }

  Future<void> _fetchRiesgoZona() async {
    if (!mounted) return;
    setState(() => _isLoadingRisk = true);
    final center = _mapController.camera.center;
    const double radius = 500.0;
    final score = await _reporteService.getRiesgoZona(center: center, radius: radius);
    if (mounted) {
      setState(() {
        _riesgoScore = score;
        _isLoadingRisk = false;
      });
    }
  }

  void _onPositionChanged(MapPosition pos, bool hasGesture) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 750), () {
      _fetchRiesgoZona();
    });
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'delito':
        return Colors.red.shade700;
      case 'falla de alumbrado':
        return Colors.orange.shade700;
      case 'bache':
        return Colors.brown.shade700;
      case 'basura':
        return Colors.grey.shade700;
      default:
        return Colors.purple.shade700;
    }
  }

  List<Marker> _buildMarkers(List<Reporte> reportes) {
    final Random random = Random();
    final Map<String, int> coordCount = {};
    final List<Marker> markers = [];
    for (var reporte in reportes) {
      final coordKey = '${reporte.location.latitude},${reporte.location.longitude}';
      coordCount[coordKey] = (coordCount[coordKey] ?? 0) + 1;
      double jitterAmount = (coordCount[coordKey]! - 1) * 0.00005;
      double angle = random.nextDouble() * 2 * pi;
      final jitteredLat = reporte.location.latitude + jitterAmount * sin(angle);
      final jitteredLon = reporte.location.longitude + jitterAmount * cos(angle);
      final jitteredPoint = LatLng(jitteredLat, jitteredLon);
      markers.add(Marker(
        width: 80.0,
        height: 80.0,
        point: jitteredPoint,
        child: GestureDetector(
          onTap: () async {
            final result = await Navigator.pushNamed(context, '/reporte_detalle', arguments: reporte.id);
            if (result == true) {
              _loadReportes();
            }
          },
          child: Icon(Icons.location_pin, color: _getCategoryColor(reporte.categoria), size: 40),
        ),
      ));
    }
    return markers;
  }

  Future<void> _centerOnUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Los servicios de ubicación están deshabilitados.')));
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    final position = await Geolocator.getCurrentPosition();
    final userLatLng = LatLng(position.latitude, position.longitude);
    _mapController.move(userLatLng, 16.0);
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = Provider.of<AuthNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerta Piura'),
        actions: [
          _buildSosSection(), // Use the new combined widget for SOS and timer
          IconButton(
            tooltip: 'Configuración',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          authNotifier.isAuthenticated
            ? Semantics(
                label: 'Cerrar Sesión',
                child: IconButton(
                  tooltip: 'Cerrar Sesión',
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    final confirmLogout = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Cerrar Sesión'),
                        content: const Text('¿Estás seguro de que quieres cerrar la sesión?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Sí, Cerrar Sesión'),
                          ),
                        ],
                      ),
                    );

                    if (confirmLogout == true) {
                      await authNotifier.logout();
                    }
                  },
                ),
              )
            : TextButton(
                child: const Text('INICIAR SESIÓN', style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.pushNamed(context, '/login'),
              ),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<List<Reporte>>(
            future: _reportesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error al cargar reportes: ${snapshot.error}'));
              }
              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _initialCenter,
                  initialZoom: 14.0,
                  onPositionChanged: _onPositionChanged,
                  onMapReady: _fetchRiesgoZona,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.mobile_app',
                  ),
                  MarkerLayer(markers: _buildMarkers(snapshot.data ?? [])),
                ],
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: _isLoadingRisk
                  ? Container(
                      margin: const EdgeInsets.only(top: 16.0),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                    )
                  : RiesgoIndicator(riesgoScore: _riesgoScore),
            ),
          ),
          const PulsingPin(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(authNotifier),
    );
  }

  // --- NEW WIDGET for the entire SOS section in the AppBar ---
  Widget _buildSosSection() {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    if (!authNotifier.isAuthenticated) return const SizedBox.shrink();

    String countdownText = '${(_sosRemainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_sosRemainingSeconds % 60).toString().padLeft(2, '0')}';
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Countdown timer, only visible when SOS is active
        if (_isSosActive)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Chip(
              label: Text(countdownText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.black54,
            ),
          ),
        
        // The SOS Button itself
        GestureDetector(
          onLongPressStart: _onSosPressStart,
          onLongPressEnd: _onSosPressEnd,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_isSosActive)
                  FadeTransition(
                    opacity: Tween<double>(begin: 0.7, end: 0.2).animate(_glowController),
                    child: Container(
                      width: 48, height: 48,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red, boxShadow: [BoxShadow(color: Colors.red, blurRadius: 15, spreadRadius: 5)])
                    ),
                  ),
                if (_isHoldingSos)
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),
                const Icon(Icons.sos, color: Colors.white, size: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButtons(AuthNotifier authNotifier) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton.small(
          heroTag: 'center_location_btn',
          onPressed: _centerOnUserLocation,
          tooltip: 'Mi Ubicación',
          child: const Icon(Icons.my_location),
        ),
        const SizedBox(height: 16),
        FloatingActionButton.extended(
          heroTag: 'create_report_btn',
          onPressed: () async {
            if (authNotifier.isAuthenticated) {
              final result = await Navigator.pushNamed(context, '/create_report');
              if (result == true) {
                _loadReportes();
              }
            } else {
              Navigator.pushNamed(context, '/login');
            }
          },
          label: const Text('Nuevo Reporte'),
          icon: const Icon(Icons.add_location_alt_outlined),
        ),
      ],
    );
  }
}