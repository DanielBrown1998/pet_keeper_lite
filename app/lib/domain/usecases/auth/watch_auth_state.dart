import '../../../core/usecases/usecase.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class WatchAuthState implements StreamUseCase<UserEntity?, NoParams> {
  final AuthRepository _repository;

  WatchAuthState(this._repository);

  @override
  Stream<UserEntity?> call(NoParams params) {
    return _repository.authStateChanges;
  }
}
