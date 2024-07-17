import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vibration/vibration.dart';

import '../../../../core/utils/logger.dart';
import '../../../place_list/data/model/place_list_model.dart';

class SearchLocationController extends ChangeNotifier {
  GoogleMapController? _googleMapController;
  bool _isBottomSheetShown = false;

  bool _isLoading = false;
  bool _isDistanceCheckActive = false;
  bool _isAlarmActive = false;
  bool _isSnackBarVisible = false;
  bool _isEntryMode = true;
  String? _pickupAddress;
  String? _snackBarMessage;
  double? _startLat;
  double? _startLong;
  double? _endLat;
  double? _endLong;

  LatLng? _pickupGeometry;
  LatLng? _currentLocation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // final NotificationService _notificationService = NotificationService();
  double _alertRadius = 50;
  List<PlaceListModel> _placeList = [];
  Timer? _distanceCheckTimer;

  GoogleMapController? get googleMapController => _googleMapController;

  bool get isBottomSheetShown => _isBottomSheetShown;

  bool get isLoading => _isLoading;

  bool get isEntryMode => _isEntryMode;

  String? get pickupAddress => _pickupAddress;

  String? get snackBarMessage => _snackBarMessage;

  double? get startLat => _startLat;

  double? get startLong => _startLong;

  double? get endLat => _endLat;

  double? get endLong => _endLong;

  LatLng? get pickupGeometry => _pickupGeometry;

  LatLng? get currentLocation => _currentLocation;

  bool get isDistanceCheckActive => _isDistanceCheckActive;

  bool get isAlarmActive => _isAlarmActive;

  bool? get isSnackBarVisible => _isSnackBarVisible;

  double get alertRadius => _alertRadius;

  List<PlaceListModel> get placeList => _placeList;

  Future<void> setGoogleMapController(
      GoogleMapController? googleMapController) async {
    _googleMapController = googleMapController;
    notifyListeners();
  }

  Future<void> setBottomSheetShown(bool? isBottomSheetShown) async {
    _isBottomSheetShown = isBottomSheetShown!;
    notifyListeners();
  }

  Future<void> setIsAlarmActive(bool isAlarmActive) async {
    _isAlarmActive = isAlarmActive;
    notifyListeners();
  }

  Future<void> setIsEntryMode(bool isEntryMode) async {
    _isEntryMode = isEntryMode;
    notifyListeners();
  }

  Future<void> setLoading(bool? isLoading) async {
    _isLoading = isLoading!;
    notifyListeners();
  }

  /// Pickup & Drop off Address and Pickup & Drop off Geometry and Distance & Duration
  Future<void> setPickupAddress(String? address) async {
    _pickupAddress = address;
    notifyListeners();
  }

  Future<void> setSnackBarMessage(String? snackBarMessage) async {
    _snackBarMessage = snackBarMessage;
    notifyListeners();
  }

  Future<void> setStartLat(double? startLat) async {
    _startLat = startLat;
    notifyListeners();
  }

  Future<void> setStartLong(double? startLong) async {
    _startLong = startLong;
    notifyListeners();
  }

  Future<void> setEndLat(double? endLat) async {
    _endLat = endLat;
    notifyListeners();
  }

  Future<void> setEndLong(double? endLong) async {
    _endLong = endLong;
    notifyListeners();
  }

  Future<void> setPickupGeometry(LatLng? latLng) async {
    _pickupGeometry = latLng;
    notifyListeners();
  }

  Future<void> setCurrentLocation(LatLng? latLng) async {
    _currentLocation = latLng;
    notifyListeners();
  }

  Future<void> setIsDistanceCheckActive(bool isDistanceCheckActive) async {
    _isDistanceCheckActive = isDistanceCheckActive;
    notifyListeners();
  }

  Future<void> setSnackBarVisible(bool? isSnackBarVisible) async {
    _isSnackBarVisible = isSnackBarVisible!;
    notifyListeners();
  }

  Future<void> setAlertRadius(double alertRadius) async {
    _alertRadius = alertRadius;
    notifyListeners();
  }

  void setPlaceList(List<PlaceListModel> list) {
    _placeList = list;
    notifyListeners();
  }

  void playAlarm() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/message_nice.mp3'));
      notifyListeners();
    } catch (error) {
      Log.e('Error playing audio: ', error: '$error');
    }
  }

  // void stopAlarm() async {
  //   await _audioPlayer.stop();
  //   notifyListeners();
  // }
  void checkDistance() async {
    if (_isDistanceCheckActive) return;

    _isDistanceCheckActive = true;

    // Use current location and pickup geometry
    LatLng? currentLocation = _currentLocation;
    LatLng? pickupGeometry = _pickupGeometry;
    double? alertRadius = _alertRadius;

    if (currentLocation == null ||
        pickupGeometry == null ||
        alertRadius == null) {
      _isDistanceCheckActive = false;
      return;
    }

    double distance = Geolocator.distanceBetween(
        currentLocation.latitude,
        currentLocation.longitude,
        pickupGeometry.latitude,
        pickupGeometry.longitude);

    Log.d("SeacrchController Distance calculated: $distance");

    bool isWithinRadius = distance <= alertRadius;

    if (_isEntryMode) {
      if (isWithinRadius) {
        if (!_isAlarmActive) {
          triggerAlarm("Entered radius!");
        }
      } else {
        _isAlarmActive = false;
      }
    } else {
      if (!isWithinRadius) {
        if (!_isAlarmActive) {
          triggerAlarm("Exited radius!");
        }
      } else {
        _isAlarmActive = false;
      }
    }

    // Schedule next check
    _distanceCheckTimer = Timer(const Duration(seconds: 2), () {
      _isDistanceCheckActive = false;
      checkDistance();
    });
  }

  void stopDistanceCheck() {
    if (_isDistanceCheckActive) {
      _isDistanceCheckActive = false;
      _isAlarmActive = false;
      _pickupGeometry = null;
      _currentLocation = null;
      notifyListeners();
    }

    stopAlarm();
    Log.d('Distance check stopped');
  }

  void triggerAlarm(String message) {
    _isAlarmActive = true;
    // _notificationService.showPersistentNotification();
    Vibration.vibrate();
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isAlarmActive) {
        timer.cancel();
      } else {
        playAlarm();
        Vibration.vibrate();
      }
    });
    notifyListeners();
    Log.d(message);
  }

  void stopAlarm() {
    _isAlarmActive = false;
    // _notificationService.stopAlarm();
    notifyListeners();
  }
}
