import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_near_me/features/place_list/presentation/view/widget/place_item.dart';
import 'package:vibration/vibration.dart';

import '../../../../core/notification_service/notification_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../search_place/presentation/provider/search_location_provider.dart';
import '../../data/model/place_list_model.dart';
import '../provider/place_list_provider.dart';

class PlaceListUI extends ConsumerStatefulWidget {
  const PlaceListUI({super.key});

  @override
  ConsumerState<PlaceListUI> createState() => _PlaceListUIState();
}

class _PlaceListUIState extends ConsumerState<PlaceListUI> {
  List<PlaceListModel> placeList = [];
  Timer? _distanceCheckTimer;

  final player = AudioPlayer();
  final NotificationBarService _notificationBarService =
      NotificationBarService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getPlaceList();
    // _notificationService.initNotification();
  }

  void getPlaceList() async {
    setState(() => isLoading = true);
    ref
        .read(placeListProvider.notifier)
        .getPlaceList()
        .then((res) => res.fold((l) {
              setState(() {
                // Handle error scenario
                Log.d('Error fetching place list: ${l.message}');
                isLoading = false;
              });
            }, (r) {
              setState(() {
                placeList = r;
                isLoading = false;
              });
            }));
  }

  void checkDistance() async {
    bool isDistanceCheckActive =
        ref.watch(searchLocationControllerProvider).isDistanceCheckActive;
    bool isEntryMode = ref.watch(searchLocationControllerProvider).isEntryMode;
    if (isDistanceCheckActive) return;

    double? alertRadius =
        ref.watch(searchLocationControllerProvider).alertRadius;
    LatLng? searchLocation =
        ref.watch(searchLocationControllerProvider).pickupGeometry;
    LatLng? currentLocation =
        ref.watch(searchLocationControllerProvider).currentLocation;
    Log.d(
        "Current Location: ${currentLocation!.latitude}, ${currentLocation.longitude}");
    Log.d(
        "Search Location: ${searchLocation!.latitude}, ${searchLocation.longitude}");

    if (currentLocation != null && searchLocation != null) {
      ref.read(searchLocationControllerProvider).setIsDistanceCheckActive(true);
      // await startBackgroundService();
      double distance = Geolocator.distanceBetween(
          currentLocation.latitude,
          currentLocation.longitude,
          searchLocation.latitude,
          searchLocation.longitude);
      Log.d("PlaceList Distance calculated: $distance");

      bool isWithinRadius = distance <= alertRadius;
      if (isEntryMode) {
        // Trigger entry alarm if within radius and not previously within radius
        if (isWithinRadius) {
          Log.d("Entered radius!");
          final isAlarmActive =
              ref.read(searchLocationControllerProvider).isAlarmActive;
          if (!isAlarmActive) {
            triggerAlarm(); // Trigger alarm if it's not already active
          }
        }
      } else {
        if (!isWithinRadius) {
          Log.d("Exited radius!");
          final isAlarmActive =
              ref.read(searchLocationControllerProvider).isAlarmActive;
          if (!isAlarmActive) {
            triggerAlarm(); // Trigger alarm if it's not already active
          }
        }
      }
    }

    // Schedule next check after 2 seconds
    _distanceCheckTimer = Timer(const Duration(seconds: 2), () {
      ref
          .read(searchLocationControllerProvider)
          .setIsDistanceCheckActive(false);
      checkDistance();
    });
  }

  void triggerAlarm() {
    ref.read(searchLocationControllerProvider).setIsAlarmActive(true);

    playAlarm();
    Vibration.vibrate();
    _notificationBarService.showNotification(
        context, "Your Location is", stopDistanceCheck);
    Timer.periodic(const Duration(seconds: 5), (timer) {
      bool isAlarmActive =
          ref.read(searchLocationControllerProvider).isAlarmActive;
      if (!isAlarmActive) {
        timer.cancel();
      } else {
        playAlarm();
        Vibration.vibrate();
      }
    });
  }

  void stopAlarm() {
    ref.read(searchLocationControllerProvider).setIsAlarmActive(false);
    player.stop();
  }

  Future<void> playAlarm() async {
    try {
      await player.play(AssetSource('sounds/message_nice.mp3'));
      Log.d('Audio play success');
    } catch (error) {
      Log.d('Audio play error: $error');
    }
  }

  void stopDistanceCheck() {
    _notificationBarService.hideNotification();
    ref.read(searchLocationControllerProvider).setPickupGeometry(null);
    ref.read(searchLocationControllerProvider).setIsDistanceCheckActive(false);
    player.stop(); // Stop the alarm sound
    stopAlarm();
    _distanceCheckTimer?.cancel();
    ref.read(searchLocationControllerProvider).setSnackBarVisible(false);
    Log.d('Distance check stopped');
  }

  void handleSwitchChange(
      WidgetRef ref, bool value, PlaceListModel place) async {
    if (value) {
      if (place.placeLatitude != null && place.placeLongitude != null) {
        ref.read(searchLocationControllerProvider).setPickupGeometry(
            LatLng(place.placeLatitude!, place.placeLongitude!));
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        ref
            .read(searchLocationControllerProvider)
            .setCurrentLocation(LatLng(position.latitude, position.longitude));
        ref
            .read(searchLocationControllerProvider)
            .setAlertRadius(place.alarmRadius!);
        ref
            .read(searchLocationControllerProvider)
            .setIsEntryMode(place.isEntryMode ?? false);

        checkDistance();
      } else {
        // showTopSnackBar("Invalid location coordinates.");
        Log.d('Invalid location coordinates.');
      }
    } else {
      stopDistanceCheck();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place List'),
      ),
      body: placeList.isEmpty
          ? const Center(child: Text("No list found"))
          : isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: placeList.length,
                  itemBuilder: (context, index) {
                    return PlaceItem(
                      place: placeList[index],
                      onSwitchChanged: (value) =>
                          handleSwitchChange(ref, value, placeList[index]),
                    );
                  },
                ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _distanceCheckTimer?.cancel();
    player.dispose();
  }
}
