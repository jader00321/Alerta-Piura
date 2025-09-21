import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_app/api/sos_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  
  service.on('startSosTracking').listen((event) async {
    final sosService = SosService();
    int ticks = 0;
    
    final prefs = await SharedPreferences.getInstance();
    final durationInSeconds = (prefs.getDouble('sosDuration') ?? 10.0).toInt() * 60;
    
    // Get contact info from local storage
    final contact = {
      "nombre": prefs.getString('contactNombre'),
      "telefono": prefs.getString('contactTelefono'),
      "mensaje": prefs.getString('contactMensaje'),
    };
    
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      
      // Send all info to the backend
      final alertId = await sosService.activateSos(
        lat: position.latitude,
        lon: position.longitude,
        emergencyContact: contact,
      );
      
      if (alertId != null) {
        // This timer will send updates back to the UI
        Timer.periodic(const Duration(seconds: 1), (timer) {
          int remaining = durationInSeconds - ticks;
          if (remaining >= 0) {
            service.invoke('update', {'sos_remaining_seconds': remaining});
          }
          ticks++;
          if (ticks >= durationInSeconds) {
            service.invoke('update', {'sos_remaining_seconds': 0});
            timer.cancel();
          }
        });

        // This timer sends location updates to the backend
        Timer.periodic(const Duration(seconds: 15), (timer) async {
          if ((ticks * 1) >= durationInSeconds) {
            timer.cancel();
            return;
          }
          final currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          await sosService.addLocationUpdate(
            alertId: alertId,
            lat: currentPosition.latitude,
            lon: currentPosition.longitude,
          );
        });
      }
    } catch (e) {
      print('BACKGROUND: Error during SOS activation: $e');
    }
  });
}

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: false,
      autoStart: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: (ServiceInstance service) => true,
    ),
  );
}