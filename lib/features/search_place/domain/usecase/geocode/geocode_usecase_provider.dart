import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_near_me/features/search_place/domain/usecase/geocode/geocode_usecase.dart';

import '../../repositories/search_location_repositories_provider.dart';

final placeToGeocodeUseCaseProvider = Provider<PlaceToGeocodeUseCase>((ref) {
  final authRepository = ref.watch(searchLocationRepositoryProvider);
  return PlaceToGeocodeUseCase(authRepository);
});
