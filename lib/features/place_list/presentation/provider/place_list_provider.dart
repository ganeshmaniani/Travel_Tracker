import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_near_me/features/place_list/domain/usecase/place_list_usecase/place_list_usecase_provider.dart';
import 'package:travel_near_me/features/place_list/presentation/provider/place_list_notifier.dart';
import 'package:travel_near_me/features/place_list/presentation/provider/place_list_state.dart';

final placeListProvider =
    StateNotifierProvider<PlaceListNotifier, PlaceListState>((ref) {
  final useCasePlaceList = ref.watch(placeListUseCaseProvider);
  return PlaceListNotifier(useCasePlaceList);
});
