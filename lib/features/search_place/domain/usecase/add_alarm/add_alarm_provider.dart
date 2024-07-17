import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/search_location_repositories_provider.dart';
import 'add_alarm_usecase.dart';

final addAlarmUseCaseProvider = Provider<AddAlarmUseCase>((ref) {
  final authRepository = ref.watch(searchLocationRepositoryProvider);
  return AddAlarmUseCase(authRepository);
});
