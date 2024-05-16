import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_near_me/features/search_plcae/domain/repositories/search_location_repositories_provider.dart';
import 'package:travel_near_me/features/search_plcae/presentation/provider/search_location_provider.dart';

import 'direction_usecase.dart';

final directionUseCaseProvider = Provider<DirectionUseCase>((ref) {
  final authRepository = ref.watch(searchLocationRepositoProvider);
  return DirectionUseCase(authRepository);
});
