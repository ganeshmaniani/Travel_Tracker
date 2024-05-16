import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionEntities extends Equatable {
  final LatLng destination;
  final LatLng origin;
  final String key;

  const DirectionEntities({
    required this.destination,
    required this.origin,
    required this.key,
  });

  @override
  List<Object> get props {
    return [
      destination,
      origin,
      key,
    ];
  }

  @override
  bool get stringify => true;

  DirectionEntities copyWith({
    final LatLng? destination,
    final LatLng? origin,
    final String? key,
  }) {
    return DirectionEntities(
      destination: destination ?? this.destination,
      origin: origin ?? this.origin,
      key: key ?? this.key,
    );
  }
}
