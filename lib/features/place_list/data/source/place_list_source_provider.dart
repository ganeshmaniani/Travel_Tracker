import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_near_me/features/place_list/data/source/place_list_source.dart';
import 'package:travel_near_me/features/place_list/data/source/place_list_source_impl.dart';

import '../../../../core/sql_service/sql_service_provider.dart';

final placeListSourceProvider = Provider<PlaceListSource>((ref) {
  final sqlApiService = ref.watch(sqlServiceProvider);
  return PlaceListSourceImpl(sqlApiService);
});
