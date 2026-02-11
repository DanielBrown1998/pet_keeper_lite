import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class GetCurrentUser implements UseCase<UserEntity?, NoParams> {
  final AuthRepository _repository;

  GetCurrentUser(this._repository);

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) async {
    final user = await _repository.currentUser;
    return Right(user);
  }
}
