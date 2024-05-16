import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_near_me/features/search_plcae/domain/repositories/search_location_repositories_provider.dart';

import 'search_location_usecase.dart';


final searchLocationUseCaseProvider = Provider<SearchLocationUseCase>((ref) {
  final authRepository = ref.watch(searchLocationRepositoProvider);
  return SearchLocationUseCase(authRepository);
});
