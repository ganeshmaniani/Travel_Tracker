import 'package:dartz/dartz.dart';
import 'package:travel_near_me/core/errors/failure.dart';
import 'package:travel_near_me/core/usecases/usecases.dart';

import '../../entities/alarm_entities.dart';
import '../../repositories/search_location_repositories.dart';

class AddAlarmUseCase implements UseCase<dynamic, AlarmEntities> {
  final SearchLocationRepository _repository;

  AddAlarmUseCase(this._repository);

  @override
  Future<Either<Failure, dynamic>> call(AlarmEntities alarmEntities) async {
    return await _repository.addAlarm(alarmEntities);
  }
}
