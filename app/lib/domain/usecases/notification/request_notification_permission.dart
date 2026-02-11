import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/notification_repository.dart';

class RequestNotificationPermission implements UseCase<void, NoParams> {
  final NotificationRepository _repository;

  RequestNotificationPermission(this._repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.requestPermission();
  }
}
