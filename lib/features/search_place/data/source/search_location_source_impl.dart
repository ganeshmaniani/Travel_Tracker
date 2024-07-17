import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart';
import 'package:travel_near_me/core/errors/failure.dart';
import 'package:travel_near_me/core/utils/logger.dart';
import 'package:travel_near_me/features/search_place/data/model/auto_complete_prediction_model.dart';
import 'package:travel_near_me/features/search_place/data/source/search_location_source.dart';
import 'package:travel_near_me/features/search_place/domain/entities/alarm_entities.dart';
import 'package:travel_near_me/features/search_place/domain/entities/place_entities.dart';

import '../../../../core/constants/app_url.dart';
import '../../../../core/service/base_api_service.dart';
import '../../../../core/sql_service/base_crud_db.dart';
import '../../../../core/sql_service/db_keys.dart';
import '../../domain/entities/direction_entities.dart';
import '../../domain/entities/place_to_geocode_entities.dart';
import '../model/direction_model.dart';
import '../model/place_to_geocode_model.dart';

class SearchLocationSourceImpl implements SearchLocationSource {
  final BaseApiServices _apiServices;

  final BaseCRUDDataBaseServices baseCRUDDataBaseServices;

  SearchLocationSourceImpl(this._apiServices, this.baseCRUDDataBaseServices);

  @override
  Future<Either<Failure, AutoCompletePrediction>> placesAutoComplete(
      PlaceEntities placeEntities) async {
    try {
      Response response = await _apiServices.getGetApiResponse(
          "${ApiUrl.autoCompletePlaceEntPoint}?input=${placeEntities.query}&components=country:IN&key=${placeEntities.key}");

      // if (response == null) {
      //   // Handle null response
      //   return const Left(Failure('NULL_RESPONSE'));
      // }

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'OK') {
          AutoCompletePrediction autoCompletePrediction =
              AutoCompletePrediction.fromJson(jsonResponse);
          return Right(autoCompletePrediction);
        } else {
          return const Left(Failure('Empty'));
        }
      } else {
        return const Left(Failure('INVALID_REQUEST'));
      }
    } catch (e) {
      Log.e("Error", error: e.toString());
      return const Left(Failure('INVALID_REQUEST'));
    }
  }

  @override
  Future<Either<Failure, PlaceToGeocodeModel>> placesToGeocode(
      PlaceToGeocodeEntities placeToGeocodeEntities) async {
    try {
      Response response = await _apiServices.getGetApiResponse(
          "${ApiUrl.placeIdToLatLangEntPoint}?place_id=${placeToGeocodeEntities.placeId}&key=${placeToGeocodeEntities.key}");
 
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'OK') {
          PlaceToGeocodeModel placeToGeocodeModel =
              PlaceToGeocodeModel.fromJson(jsonResponse);
          return Right(placeToGeocodeModel);
        } else {
          log(jsonResponse.toString());
          return const Left(Failure('Empty'));
        }
      } else {
        return const Left(Failure('INVALID_REQUEST  '));
      }
    } catch (e) {
      log("Error: ${e.toString()}");
      return const Left(Failure('INVALID_REQUEST'));
    }
  }

  @override
  Future<Either<Failure, Directions>> getDirection(
      DirectionEntities directionEntities) async {
    final origin = directionEntities.origin;
    final destination = directionEntities.destination;
    try {
      Response response = await _apiServices.getGetApiResponse(
          "${ApiUrl.directionEntPoint}?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=${directionEntities.key}");

      log("Responseadsda: ${response.statusCode}");
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'OK') {
          Directions directions = Directions.fromMap(jsonResponse);
          return Right(directions);
        } else {
          log(jsonResponse.toString());
          return const Left(Failure('Empty'));
        }
      } else {
        return const Left(Failure('INVALID_REQUEST  '));
      }
    } catch (e) {
      log("Error: ${e.toString()}");
      return const Left(Failure('INVALID_REQUEST'));
    }
  }

  @override
  Future<Either<Failure, dynamic>> addAlarm(AlarmEntities alarmEntities) async {
    try {
      var data = {
        DBKeys.dbAlarmName: alarmEntities.alarmName,
        DBKeys.dbAlarmRadius: alarmEntities.alertRadius,
        DBKeys.dbPlaceDescription: alarmEntities.placeDescription,
        DBKeys.dbPlaceLatitude: alarmEntities.placeLatitude,
        DBKeys.dbPlaceLongitude: alarmEntities.placeLongitude,
        DBKeys.dbIsEntry: alarmEntities.isEntryMode ? 1 : 0,
      };
      Log.t("RESPONSE FOR AlarmDetail:${data.toString()}");
      Log.i("DEBUG - isEntryMode: ${alarmEntities.isEntryMode}");
      var response =
          await baseCRUDDataBaseServices.insertData(DBKeys.dbAlarmTable, data);
      log("RESPONSE FOR AlarmDetailAdded:${response.toString()}");
      if (response != null) {
        return Right(response);
      } else {
        return const Left(Failure("Please Enter detail"));
      }
    } catch (e) {
      return Left(Failure("CatchError:${e.toString()}"));
    }
  }
}
