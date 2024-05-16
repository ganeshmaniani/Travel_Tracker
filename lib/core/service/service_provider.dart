import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_near_me/core/service/base_api_service.dart';

import 'network_api_service.dart';

final serviceProvider = Provider<BaseApiServices>((ref) {
  return NetworkApiService();
});
