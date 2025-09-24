import 'dart:async';
import 'dart:ui';
//import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_app/api/sos_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- THIS IS THE ENTRY POINT FOR THE BACKGROUND ISOLATE ---
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  Timer? locationTimer; 

  service.on('stopTracking').listen((event) {
    locationTimer?.cancel();
    service.stopSelf(); // Stops the entire background service
  });
  // --- SERVICE SETUP ---
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // This is the listener for commands from the app UI
  service.on('startSosTracking').listen((event) async {
    final sosService = SosService();
    int ticks = 0;
    final Map<String, dynamic> eventData = event!;
    final int durationInSeconds = eventData['durationInSeconds'];
    final prefs = await SharedPreferences.getInstance();
    
    // --- THIS IS THE CRITICAL FIX ---
    // Show a mandatory notification to comply with Android foreground service rules.
    flutterLocalNotificationsPlugin.show(
      888, // A unique ID for this notification
      'SOS ACTIVO',
      'Transmitiendo tu ubicación de emergencia...',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'sos_channel',
          'Alerta SOS',
          channelDescription: 'Notificación persistente mientras el SOS está activo.',
          icon: 'ic_bg_service_small', // This should be a small icon in android/app/src/main/res/mipmap
          ongoing: true, // Makes the notification non-dismissible
        ),
      ),
    );

    // --- The rest of the logic remains largely the same ---
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      
      final contact = {
        "nombre": prefs.getString('contactNombre'),
        "telefono": prefs.getString('contactTelefono'),
        "mensaje": prefs.getString('contactMensaje'),
      };
      
      final alertId = await sosService.activateSos(
        lat: position.latitude,
        lon: position.longitude,
        emergencyContact: contact,
        durationInSeconds: durationInSeconds,
      );
      
      if (alertId != null) {
        // We use one timer to manage everything to be more efficient
         locationTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
          // Send UI update every second
          int remaining = durationInSeconds - ticks;
          if (remaining >= 0) {
            service.invoke('update', {'sos_remaining_seconds': remaining});
          }
          ticks++;
          
          // Send location update to backend every 15 seconds
          if (ticks % 15 == 0) {
             final currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
             await sosService.addLocationUpdate(
               alertId: alertId,
               lat: currentPosition.latitude,
               lon: currentPosition.longitude,
             );
          }

          // Stop when duration is reached
          if ((ticks * 15) >= durationInSeconds) {
            timer.cancel();
            await sosService.deactivateSos(alertId);
            service.invoke('update', {'sos_remaining_seconds': 0});
            //flutterLocalNotificationsPlugin.cancel(888); // Hide the notification
          }
        });
      }
    } catch (e) {
      print('BACKGROUND: Error during SOS activation: $e');
      //flutterLocalNotificationsPlugin.cancel(888); // Ensure notification is cancelled on error
    }
  });

  // Listener to stop the service if needed
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}

// --- INITIALIZATION LOGIC (REMAINS THE SAME) ---
Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();
  
  // This is the notification channel setup
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'sos_channel', // id
    'Alertas SOS', // title
    description: 'Este canal se usa para las notificaciones de SOS activo.',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
      
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      notificationChannelId: 'sos_channel',
      initialNotificationTitle: 'Servicio de Alerta Piura',
      initialNotificationContent: 'El servicio está listo para emergencias.',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: (ServiceInstance service) => true,
    ),
  );
}