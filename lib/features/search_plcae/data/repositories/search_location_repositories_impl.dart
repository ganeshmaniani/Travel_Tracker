import 'package:dartz/dartz.dart';
import 'package:travel_near_me/core/errors/failure.dart';
import 'package:travel_near_me/features/search_plcae/data/model/auto_complete_prediction_model.dart';
import 'package:travel_near_me/features/search_plcae/data/source/search_location_source.dart';
import 'package:travel_near_me/features/search_plcae/domain/entities/place_entities.dart';
import 'package:travel_near_me/features/search_plcae/domain/repositories/search_location_repositories.dart';

import '../../domain/entities/direction_entities.dart';
import '../../domain/entities/place_to_geocode_entities.dart';
import '../model/direction_model.dart';
import '../model/place_to_geocode_model.dart';

class SearchLocationRepositoryImpl implements SearchLocationRepository {
  final SearchLocationSource searchLocationSource;
  SearchLocationRepositoryImpl(this.searchLocationSource);
  @override
  Future<Either<Failure, AutoCompletePrediction>> placesAutoComplete(
      PlaceEntities placeEntities) async {
    return await searchLocationSource.placesAutoComplete(placeEntities);
  }@override
  Future<Either<Failure, PlaceToGeocodeModel>> placesToGeocode(
      PlaceToGeocodeEntities placeToGeocodeEntities) async {
    return await searchLocationSource.placesToGeocode(placeToGeocodeEntities);
  }

  @override
  Future<Either<Failure, Directions>> getDirection(
      DirectionEntities directionEntities) async {
    return await searchLocationSource.getDirection(directionEntities);
  }
}
