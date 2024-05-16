import 'package:dartz/dartz.dart';
import 'package:travel_near_me/features/search_plcae/domain/repositories/search_location_repositories.dart';

import '../../../../../core/errors/errors.dart';
import '../../../../../core/usecases/usecases.dart';
import '../../../data/model/direction_model.dart';
import '../../entities/direction_entities.dart';


class DirectionUseCase implements UseCase<Directions, DirectionEntities> {
  final SearchLocationRepository _repository;
  DirectionUseCase(this._repository);

  @override
  Future<Either<Failure, Directions>> call(
      DirectionEntities directionEntities) async {
    return await _repository.getDirection(directionEntities);
  }
}
