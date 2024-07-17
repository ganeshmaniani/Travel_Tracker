import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_near_me/features/place_list/data/repositories/place_list_repo_impl.dart';
import 'package:travel_near_me/features/place_list/data/source/place_list_source_provider.dart';
import 'package:travel_near_me/features/place_list/domain/repositories/place_list_repository.dart';

final placeListRepositoryProvider = Provider<PlaceListRepository>((ref) {
  final remoteDataSource = ref.watch(placeListSourceProvider);
  return PlaceListRepositoryImpl(remoteDataSource);
});
