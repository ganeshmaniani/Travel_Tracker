import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_near_me/features/search_place/domain/repositories/search_location_repositories_provider.dart';

import 'direction_usecase.dart';

final directionUseCaseProvider = Provider<DirectionUseCase>((ref) {
  final authRepository = ref.watch(searchLocationRepositoryProvider);
  return DirectionUseCase(authRepository);
});
