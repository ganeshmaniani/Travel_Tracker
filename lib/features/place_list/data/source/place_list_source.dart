import 'package:dartz/dartz.dart';
import 'package:travel_near_me/core/errors/errors.dart';

import '../model/place_list_model.dart';

abstract class PlaceListSource {
  Future<Either<Failure, List<PlaceListModel>>> getPlaceList();
}
