import 'package:dartz/dartz.dart';

import '../../../../core/errors/errors.dart';
import '../../data/model/auto_complete_prediction_model.dart';
import '../../data/model/direction_model.dart';
import '../../data/model/place_to_geocode_model.dart';
import '../entities/alarm_entities.dart';
import '../entities/direction_entities.dart';
import '../entities/place_entities.dart';
import '../entities/place_to_geocode_entities.dart';

abstract class SearchLocationRepository {
  Future<Either<Failure, AutoCompletePrediction>> placesAutoComplete(
      PlaceEntities placeEntities);

  Future<Either<Failure, PlaceToGeocodeModel>> placesToGeocode(
      PlaceToGeocodeEntities placeToGeocodeEntities);

  Future<Either<Failure, Directions>> getDirection(
      DirectionEntities directionEntities);

  Future<Either<Failure, dynamic>> addAlarm(AlarmEntities alarmEntities);
}
