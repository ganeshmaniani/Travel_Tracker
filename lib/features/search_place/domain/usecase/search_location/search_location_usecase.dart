import 'package:dartz/dartz.dart';
import 'package:travel_near_me/features/search_place/domain/repositories/search_location_repositories.dart';

import '../../../../../core/errors/errors.dart';
import '../../../../../core/usecases/usecases.dart';
import '../../../data/model/auto_complete_prediction_model.dart';
import '../../entities/place_entities.dart';

class SearchLocationUseCase
    implements UseCase<AutoCompletePrediction, PlaceEntities> {
  final SearchLocationRepository _repository;

  SearchLocationUseCase(this._repository);

  @override
  Future<Either<Failure, AutoCompletePrediction>> call(
      PlaceEntities placeEntities) async {
    return await _repository.placesAutoComplete(placeEntities);
  }
}
