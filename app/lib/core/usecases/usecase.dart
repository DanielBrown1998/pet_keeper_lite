import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base class for use cases that return a Future
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Base class for use cases that return a Stream
abstract class StreamUseCase<Type, Params> {
  Stream<Type> call(Params params);
}

/// Used when a use case doesn't require any parameters
class NoParams {
  const NoParams();
}
