import 'package:flutter/services.dart';
import 'package:travel_near_me/core/utils/logger.dart';

class BackgroundService {
  static const _channel = MethodChannel('com.vgt.travel_near_me/service');

  static Future<void> startService({
    required double startLat,
    required double startLong,
    required double endLat,
    required double endLong,
  }) async {
    try {
      await _channel.invokeMethod('run', {
        'start_lat': startLat.toString(),
        'start_long': startLong.toString(),
        'end_lat': endLat.toString(),
        'end_long': endLong.toString(),
      });
    } on PlatformException catch (e) {
      Log.e("Failed to start service: ", error: '${e.message}');
    }
  }

  static Future<void> stopService() async {
    try {
      await _channel.invokeMethod('stop');
    } on PlatformException catch (e) {
      Log.e("Failed to stop service:", error: ' ${e.message}');
    }
  }
}
