import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchLocationController extends ChangeNotifier {
  String? _pickupAddress;
  String? _dropOffAddress;
  LatLng? _pickupGeometry;
  LatLng? _dropOffGeometry;
  int? _distance;
  String? _duration;
  String? get pickupAddress => _pickupAddress;

  String? get dropOffAddress => _dropOffAddress;

  LatLng? get pickupGeometry => _pickupGeometry;

  LatLng? get dropOffGeometry => _dropOffGeometry;

  int? get distance => _distance;

  String? get duration => _duration;

  /// Pickup & Drop off Address and Pickup & Drop off Geometry and Distance & Duration
  Future<void> setPickupAddress(String? address) async {
    _pickupAddress = address;
    notifyListeners();
  }

  Future<void> setPickupGeometry(LatLng? latLng) async {
    _pickupGeometry = latLng;
    notifyListeners();
  }

  Future<void> setDropOffAddress(String? address) async {
    _dropOffAddress = address;
    notifyListeners();
  }

  Future<void> setDropOffGeometry(LatLng? latLng) async {
    _dropOffGeometry = latLng;
    notifyListeners();
  }

  Future<void> setDistance(int? distance) async {
    _distance = distance;
    notifyListeners();
  }

  Future<void> setDuration(String? duration) async {
    _duration = duration;
    notifyListeners();
  }
}
