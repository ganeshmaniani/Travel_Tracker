import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_near_me/features/search_place/domain/repositories/search_location_repositories.dart';

import '../../data/repositories/search_location_repositories_impl.dart';
import '../../data/source/search_location_source_provider.dart';

final searchLocationRepositoryProvider =
    Provider<SearchLocationRepository>((ref) {
  final remoteSource = ref.watch(searchLocationSourceProvider);
  return SearchLocationRepositoryImpl(remoteSource);
});
