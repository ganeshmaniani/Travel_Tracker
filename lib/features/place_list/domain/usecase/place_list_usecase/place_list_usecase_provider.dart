import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_near_me/features/place_list/domain/repositories/place_list_repository_provider.dart';
import 'package:travel_near_me/features/place_list/domain/usecase/place_list_usecase/place_list_usecase.dart';

final placeListUseCaseProvider = Provider<PlaceListUseCase>((ref) {
  final placeListRepository = ref.watch(placeListRepositoryProvider);
  return PlaceListUseCase(placeListRepository);
});
