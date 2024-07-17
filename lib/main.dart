import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:travel_near_me/app/app.dart';
import 'package:travel_near_me/core/notification_service/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initNotification();
  await Permission.notification.request();
  await Permission.location.request();
  await initializeService();

  runApp(const ProviderScope(child: TravelNearMe()));
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(),
  );
  await service.startService();
  FlutterBackgroundService().invoke('setAsBackground');
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
      // Log.d("Background service is running");
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
    // Log.d("Background service is Stoped");
  });
  Timer.periodic(const Duration(seconds: 2), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
            title: "Vin green Service",
            content: "Updated at ${DateTime.now()}");
      }
    }

    // Log.d("Background service is running");
  });
}

//
// Future<void> initializeService() async {
//   final service = FlutterBackgroundService();
//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       autoStart: true,
//       isForegroundMode: true,
//     ),
//     iosConfiguration: IosConfiguration(
//       autoStart: true,
//       onForeground: onStart,
//       onBackground: onIosBackground,
//     ),
//   );
// }
//
// void onStart(ServiceInstance service) {
//   service.on('task').listen((event) {
//     callback();
//   });
//   Timer.periodic(const Duration(seconds: 10), (timer) {
//     service.invoke('task');
//   });
// }
//
// @pragma('vm:entry-point')
// Future<bool> onIosBackground(ServiceInstance service) async {
//   WidgetsFlutterBinding.ensureInitialized();
//   DartPluginRegistrant.ensureInitialized();
//   service.on('task').listen((event) {
//     callback();
//   });
//   Timer.periodic(const Duration(seconds: 50), (timer) {
//     service.invoke('task');
//   });
//   return true;
// }
//
// void callback() async {
//   try {
//     // final data = await repository.get();
//     Log.d('Retrieved data: ');
//   } catch (e) {
//     Log.d('Error retrieving data: $e');
//   }
// }
