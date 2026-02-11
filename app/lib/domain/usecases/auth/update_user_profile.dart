import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/auth_repository.dart';

class UpdateUserProfileParams {
  final String? displayName;
  final String? familyCode;

  const UpdateUserProfileParams({this.displayName, this.familyCode});
}

class UpdateUserProfile implements UseCase<void, UpdateUserProfileParams> {
  final AuthRepository _repository;

  UpdateUserProfile(this._repository);

  @override
  Future<Either<Failure, void>> call(UpdateUserProfileParams params) {
    return _repository.updateUserProfile(
      displayName: params.displayName,
      familyCode: params.familyCode,
    );
  }
}
