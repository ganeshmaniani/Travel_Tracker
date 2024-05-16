import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart';
import 'package:travel_near_me/core/errors/failure.dart';
import 'package:travel_near_me/features/search_plcae/data/model/auto_complete_prediction_model.dart';
import 'package:travel_near_me/features/search_plcae/data/source/search_location_source.dart';
import 'package:travel_near_me/features/search_plcae/domain/entities/place_entities.dart';
import 'package:travel_near_me/features/search_plcae/domain/repositories/search_location_repositories.dart';

import '../../../../core/constants/app_url.dart';
import '../../../../core/service/base_api_service.dart';
import '../../domain/entities/direction_entities.dart';
import '../../domain/entities/place_to_geocode_entities.dart';
import '../model/direction_model.dart';
import '../model/place_to_geocode_model.dart';

class SearchLocationSourceImpl implements SearchLocationSource {
  final BaseApiServices _apiServices;

  SearchLocationSourceImpl(this._apiServices);

  @override
  Future<Either<Failure, AutoCompletePrediction>> placesAutoComplete(
      PlaceEntities placeEntities) async {
    try {
      Response response = await _apiServices.getGetApiResponse(
          "${ApiUrl.autoCompletePlaceEntPoint}?input=${placeEntities.query}&components=country:IN&key=${placeEntities.key}");
      if (response == null) {
        // Handle null response
        return const Left(Failure('NULL_RESPONSE'));
      }
      log(response.body.toString());
      log("Responsesdasdas: ${response.statusCode}");
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'OK') {
          AutoCompletePrediction autoCompletePrediction =
              AutoCompletePrediction.fromJson(jsonResponse);
          return Right(autoCompletePrediction);
        } else {
          log(jsonResponse.toString());
          return const Left(Failure('Empty'));
        }
      } else {
        return const Left(Failure('INVALID_REQUEST'));
      }
    } catch (e) {
      log("Error: ${e.toString()}");
      return const Left(Failure('INVALID_REQUEST'));
    }
  }

  @override
  Future<Either<Failure, PlaceToGeocodeModel>> placesToGeocode(
      PlaceToGeocodeEntities placeToGeocodeEntities) async {
    try {
      Response response = await _apiServices.getGetApiResponse(
          "${ApiUrl.placeIdToLatLangEntPoint}?place_id=${placeToGeocodeEntities.placeId}&key=${placeToGeocodeEntities.key}");

      log("Responsess: ${response.statusCode}");
      log("Responsess: ${response.body.toString()}");
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
}
