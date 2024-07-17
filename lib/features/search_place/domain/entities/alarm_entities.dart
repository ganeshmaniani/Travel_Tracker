import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AlarmEntities extends Equatable {
  final String alarmName;
  final double alertRadius; 
  final String placeDescription;
  final double placeLatitude;
  final double placeLongitude;
  final bool isEntryMode;

  const AlarmEntities({
    required this.alarmName,
    required this.alertRadius, 
    required this.placeDescription,
    required this.placeLatitude,
    required this.placeLongitude,
    required this.isEntryMode,
  });

  @override
  List<Object?> get props => [
        alarmName,
        alertRadius, 
        placeDescription,
        placeLatitude,
        placeLongitude,
        isEntryMode
      ];

  @override
  bool get stringify => true;

  AlarmEntities copyWith({
    final String? alarmName,
    final double? alertRadius, 
    final String? placeDescription,
    final double? placeLatitude,
    final double? placeLongitude,
    final bool? isEntryMode,
  }) {
    return AlarmEntities(
      alarmName: alarmName ?? this.alarmName,
      alertRadius: alertRadius ?? this.alertRadius, 
      placeDescription: placeDescription ?? this.placeDescription,
      placeLatitude: placeLatitude ?? this.placeLatitude,
      placeLongitude: placeLongitude ?? this.placeLongitude,
      isEntryMode: isEntryMode ?? this.isEntryMode,
    );
  }
}
