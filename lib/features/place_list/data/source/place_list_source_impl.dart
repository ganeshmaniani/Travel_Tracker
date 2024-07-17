import 'package:dartz/dartz.dart';
import 'package:travel_near_me/core/errors/failure.dart';
import 'package:travel_near_me/features/place_list/data/source/place_list_source.dart';

import '../../../../core/sql_service/sql_services.dart';
import '../../../../core/utils/logger.dart';
import '../model/place_list_model.dart';

class PlaceListSourceImpl implements PlaceListSource {
  final BaseCRUDDataBaseServices baseCRUDDataBaseServices;

  PlaceListSourceImpl(this.baseCRUDDataBaseServices);

  @override
  Future<Either<Failure, List<PlaceListModel>>> getPlaceList() async {
    try {
      var response =
          await baseCRUDDataBaseServices.getData(DBKeys.dbAlarmTable);
      Log.d("RESPONSE FOR AlarmDetailAdded:${response.toString()}");
      if (response != null && response is List<Map<String, dynamic>>) {
        List<PlaceListModel> placeListModel =
            response.map((data) => PlaceListModel.fromJson(data)).toList();
        Log.d(placeListModel.toString());
        return Right(placeListModel);
      } else {
        return const Left(Failure("Unable to get list"));
      }
    } catch (e) {
      return Left(Failure("CatchError:${e.toString()}"));
    }
  }
}
