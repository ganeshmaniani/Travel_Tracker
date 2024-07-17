import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';

class TravelBackgroundRunning {
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
  }

  @pragma('vm:entry-point')
  void onStart(ServiceInstance service) async {
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }
    service.on('stopService').listen((event) {
      service.stopSelf();
    });
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          service.setForegroundNotificationInfo(
              title: "Vin green Service",
              content: "Updated at ${DateTime.now()}");
        }
      }
    });
  }
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
}
