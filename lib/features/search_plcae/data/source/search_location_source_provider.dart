import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_near_me/core/service/service_provider.dart';
import 'package:travel_near_me/features/search_plcae/data/source/search_location_source.dart';
import 'package:travel_near_me/features/search_plcae/data/source/search_location_source_impl.dart';

final searchLocationSourceProvider = Provider<SearchLocationSource>((ref) {
  final apiServices = ref.watch(serviceProvider);
  return SearchLocationSourceImpl(apiServices);
});
