import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_near_me/features/search_place/presentation/provider/search_location_state.dart';

import '../../../../core/errors/errors.dart';
import '../../data/model/auto_complete_prediction_model.dart';
import '../../data/model/direction_model.dart';
import '../../data/model/place_to_geocode_model.dart';
import '../../domain/entities/alarm_entities.dart';
import '../../domain/entities/direction_entities.dart';
import '../../domain/entities/place_entities.dart';
import '../../domain/entities/place_to_geocode_entities.dart';
import '../../domain/usecase/add_alarm/add_alarm_usecase.dart';
import '../../domain/usecase/direction/direction.dart';
import '../../domain/usecase/geocode/geocode.dart';
import '../../domain/usecase/search_location/search_location_usecase.dart';

class SearchLocationNotifier extends StateNotifier<SearchLocationState> {
  final SearchLocationUseCase _searchLocationUseCase;
  final PlaceToGeocodeUseCase _placeToGeocodeUseCase;
  final DirectionUseCase _directionUseCase;
  final AddAlarmUseCase _addAlarmUseCase;

  SearchLocationNotifier(
    this._searchLocationUseCase,
    this._placeToGeocodeUseCase,
    this._directionUseCase,
    this._addAlarmUseCase,
  ) : super(const SearchLocationState.initial());

  Future<Either<Failure, AutoCompletePrediction>> autoCompletePlaceList(
      PlaceEntities placeEntities) async {
    state.copyWith(isLoading: true);
    final result = await _searchLocationUseCase(placeEntities);
    state.copyWith(isLoading: false);
    return result;
  }

  Future<Either<Failure, PlaceToGeocodeModel>> placeToGeocode(
      PlaceToGeocodeEntities placeToGeocodeEntities) async {
    state.copyWith(isLoading: true);
    final result = await _placeToGeocodeUseCase(placeToGeocodeEntities);
    state.copyWith(isLoading: false);
    return result;
  }

  Future<Either<Failure, Directions>> getDirection(
      DirectionEntities directionEntities) async {
    state.copyWith(isLoading: true);
    final result = await _directionUseCase(directionEntities);
    state.copyWith(isLoading: false);
    return result;
  }

  Future<Either<Failure, dynamic>> addAlarm(AlarmEntities alarmEntities) async {
    state.copyWith(isLoading: true);
    final result = await _addAlarmUseCase(alarmEntities);
    state.copyWith(isLoading: false);
    return result;
  }
}
