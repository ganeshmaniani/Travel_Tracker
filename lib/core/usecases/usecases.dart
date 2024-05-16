import 'package:dartz/dartz.dart';
import 'package:travel_near_me/core/errors/failure.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
