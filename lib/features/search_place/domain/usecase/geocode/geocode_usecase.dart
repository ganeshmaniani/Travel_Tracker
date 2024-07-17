import 'package:dartz/dartz.dart';
import 'package:travel_near_me/features/search_place/domain/repositories/search_location_repositories.dart';

import '../../../../../core/errors/errors.dart';
import '../../../../../core/usecases/usecases.dart';
import '../../../data/model/place_to_geocode_model.dart';
import '../../entities/place_to_geocode_entities.dart';

class PlaceToGeocodeUseCase
    implements UseCase<PlaceToGeocodeModel, PlaceToGeocodeEntities> {
  final SearchLocationRepository _repository;

  PlaceToGeocodeUseCase(this._repository);

  @override
  Future<Either<Failure, PlaceToGeocodeModel>> call(
      PlaceToGeocodeEntities placeToGeocodeEntities) async {
    return await _repository.placesToGeocode(placeToGeocodeEntities);
  }
}
