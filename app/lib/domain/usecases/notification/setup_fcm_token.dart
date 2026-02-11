import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/notification_repository.dart';

/// Setup FCM token: request permission, get token, and save to user profile
class SetupFcmToken implements UseCase<void, NoParams> {
  final NotificationRepository _notificationRepository;
  final AuthRepository _authRepository;

  SetupFcmToken(this._notificationRepository, this._authRepository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    // Request permission
    final permissionResult = await _notificationRepository.requestPermission();
    if (permissionResult.isLeft()) {
      return permissionResult;
    }

    // Get token
    final tokenResult = await _notificationRepository.getToken();

    return tokenResult.fold((failure) => Left(failure), (token) async {
      if (token != null) {
        return _authRepository.updateFcmToken(token);
      }
      return const Right(null);
    });
  }
}
