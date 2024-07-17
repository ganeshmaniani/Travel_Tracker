import 'package:dartz/dartz.dart';
import 'package:travel_near_me/core/errors/failure.dart';

import '../../data/model/place_list_model.dart';

abstract class PlaceListRepository {
  Future<Either<Failure, List<PlaceListModel>>> getPlaceList();
}
