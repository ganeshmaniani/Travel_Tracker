import 'package:dartz/dartz.dart';
import 'package:travel_near_me/features/place_list/data/model/place_list_model.dart';
import 'package:travel_near_me/features/place_list/domain/repositories/place_list_repository.dart';

import '../../../../../core/errors/failure.dart';

class PlaceListUseCase {
  final PlaceListRepository placeListRepository;

  PlaceListUseCase(this.placeListRepository);

  Future<Either<Failure, List<PlaceListModel>>> call() async {
    return await placeListRepository.getPlaceList();
  }
}
