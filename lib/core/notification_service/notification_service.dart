import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:travel_near_me/core/utils/logger.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<String> _notificationActionStreamController =
      StreamController<String>.broadcast();

  Stream<String> get actionStream => _notificationActionStreamController.stream;
  VoidCallback? stopDistanceCheckCallback;

  Future<void> initNotification() async {
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("notification_icon_push");

    // iOS initialization settings
    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {
          // Handle iOS foreground notification
          log("iOS Notification Received: $title, $body, $payload");
        });
    // General initialization settings
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    ); // Initialize the plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        Log.d('ActionId:${response.actionId}');
        if (response.actionId == 'stop') {
          _notificationActionStreamController.add('stop');
          stopDistanceCheckCallback?.call();
        }
        Log.w("Notification clicked with payload: ${response.payload}");
      },
    );
    await _createNotificationChannel();
  }

  // Create a default notification channel for Android
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'channelId', // ID for the notification channel
      'Channel Name', // Name of the channel
      description: 'Channel description', // Description of the channel
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> showPersistentNotification(
      {int id = 0, String? title, String? body, String? payload}) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channelId',
      'Channel Name',
      channelDescription: 'Channel description',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      playSound: false,
      // Reference to custom sound
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('stop', 'Stop', showsUserInterface: true),
      ],
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidNotificationDetails,
    );
    await flutterLocalNotificationsPlugin
        .show(id, title, body, platformChannelSpecifics, payload: payload);
  }

  Future<void> stopAlarm() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }
}

class CustomNotificationBar extends StatelessWidget {
  final String message;
  final VoidCallback onClose;

  const CustomNotificationBar({
    Key? key,
    required this.message,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationBarService {
  static final NotificationBarService _instance =
      NotificationBarService._internal();

  factory NotificationBarService() => _instance;

  NotificationBarService._internal();

  OverlayEntry? _overlayEntry;

  void showNotification(
      BuildContext context, String message, VoidCallback onClose) {
    _overlayEntry = _createOverlayEntry(context, message, onClose);
    Overlay.of(context).insert(_overlayEntry!);
  }

  hideNotification() {
    _overlayEntry?.remove();
  }

  OverlayEntry _createOverlayEntry(
      BuildContext context, String message, VoidCallback onClose) {
    return OverlayEntry(
      builder: (context) => Positioned(
          top: MediaQuery.of(context).padding.top,
          left: 16,
          right: 16,
          child: TopSnackBar(
            message: message,
            onClose: () {
              _overlayEntry?.remove();
              onClose();
            },
          )),
    );
  }
}

class TopSnackBar extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final VoidCallback onClose;

  const TopSnackBar({
    required this.message,
    this.backgroundColor = Colors.red,
    required this.onClose,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 4),
                blurRadius: 10.0,
                spreadRadius: 1.0),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}
