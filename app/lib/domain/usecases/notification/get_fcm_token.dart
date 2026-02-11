import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/notification_repository.dart';

class GetFcmToken implements UseCase<String?, NoParams> {
  final NotificationRepository _repository;

  GetFcmToken(this._repository);

  @override
  Future<Either<Failure, String?>> call(NoParams params) {
    return _repository.getToken();
  }
}
