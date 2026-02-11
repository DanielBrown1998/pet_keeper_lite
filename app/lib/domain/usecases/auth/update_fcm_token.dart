import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/auth_repository.dart';

class UpdateFcmToken implements UseCase<void, String> {
  final AuthRepository _repository;

  UpdateFcmToken(this._repository);

  @override
  Future<Either<Failure, void>> call(String token) {
    return _repository.updateFcmToken(token);
  }
}
