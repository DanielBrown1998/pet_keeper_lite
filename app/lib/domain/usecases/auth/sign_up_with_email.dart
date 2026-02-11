import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class SignUpWithEmailParams {
  final String email;
  final String password;
  final String? displayName;

  const SignUpWithEmailParams({
    required this.email,
    required this.password,
    this.displayName,
  });
}

class SignUpWithEmail implements UseCase<UserEntity, SignUpWithEmailParams> {
  final AuthRepository _repository;

  SignUpWithEmail(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpWithEmailParams params) {
    return _repository.signUpWithEmailAndPassword(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
    );
  }
}
