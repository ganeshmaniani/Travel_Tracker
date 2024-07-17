import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_near_me/features/place_list/data/model/place_list_model.dart';
import 'package:travel_near_me/features/place_list/domain/usecase/place_list_usecase/place_list_usecase.dart';
import 'package:travel_near_me/features/place_list/presentation/provider/place_list_state.dart';

import '../../../../core/errors/errors.dart';

class PlaceListNotifier extends StateNotifier<PlaceListState> {
  final PlaceListUseCase _placeListUseCase;

  PlaceListNotifier(this._placeListUseCase)
      : super(const PlaceListState.initial());

  Future<Either<Failure, List<PlaceListModel>>> getPlaceList() async {
    state.copyWith(isLoading: true);
    final result = await _placeListUseCase();
    state.copyWith(isLoading: false);
    return result;
  }
}
