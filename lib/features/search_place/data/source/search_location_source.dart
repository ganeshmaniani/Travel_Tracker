import 'package:dartz/dartz.dart';

import '../../../../core/errors/errors.dart';
import '../../domain/entities/alarm_entities.dart';
import '../../domain/entities/direction_entities.dart';
import '../../domain/entities/place_entities.dart';
import '../../domain/entities/place_to_geocode_entities.dart';
import '../model/auto_complete_prediction_model.dart';
import '../model/direction_model.dart';
import '../model/place_to_geocode_model.dart';

abstract class SearchLocationSource {
  Future<Either<Failure, AutoCompletePrediction>> placesAutoComplete(
      PlaceEntities placeEntities);

  Future<Either<Failure, PlaceToGeocodeModel>> placesToGeocode(
      PlaceToGeocodeEntities placeToGeocodeEntities);

  Future<Either<Failure, Directions>> getDirection(
      DirectionEntities directionEntities);

  Future<Either<Failure, dynamic>> addAlarm(AlarmEntities alarmEntities);
}
