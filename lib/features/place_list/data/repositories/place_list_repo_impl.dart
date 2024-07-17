import 'package:dartz/dartz.dart';
import 'package:travel_near_me/core/errors/failure.dart';
import 'package:travel_near_me/features/place_list/data/source/place_list_source.dart';
import 'package:travel_near_me/features/place_list/domain/repositories/place_list_repository.dart';

import '../model/place_list_model.dart';

class PlaceListRepositoryImpl implements PlaceListRepository {
  final PlaceListSource placeListSource;

  PlaceListRepositoryImpl(this.placeListSource);

  @override
  Future<Either<Failure, List<PlaceListModel>>> getPlaceList() async {
    return placeListSource.getPlaceList();
  }
}
