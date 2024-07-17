import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_near_me/features/search_place/presentation/provider/search_location_notifier.dart';

import '../../domain/usecase/add_alarm/add_alarm_provider.dart';
import '../../domain/usecase/direction/direction.dart';
import '../../domain/usecase/geocode/geocode.dart';
import '../../domain/usecase/search_location/search_location_usecase_provider.dart';
import 'search_location_changenotifier.dart';
import 'search_location_state.dart';

final searchLocationProvider =
    StateNotifierProvider<SearchLocationNotifier, SearchLocationState>((ref) {
  final useCaseSearchLocation = ref.watch(searchLocationUseCaseProvider);
  final useCasePlaceToGeocode = ref.watch(placeToGeocodeUseCaseProvider);
  final useCaseDirection = ref.watch(directionUseCaseProvider);
  final useCaseAddAlarm = ref.watch(addAlarmUseCaseProvider);
  return SearchLocationNotifier(useCaseSearchLocation, useCasePlaceToGeocode,
      useCaseDirection, useCaseAddAlarm);
});
final searchLocationControllerProvider =
    ChangeNotifierProvider<SearchLocationController>((ref) {
  return SearchLocationController();
});
