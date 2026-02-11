import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/notification_repository.dart';

class NotifyFamilyParams {
  final String petId;
  final String message;

  const NotifyFamilyParams({required this.petId, required this.message});
}

class NotifyFamily implements UseCase<void, NotifyFamilyParams> {
  final NotificationRepository _repository;

  NotifyFamily(this._repository);

  @override
  Future<Either<Failure, void>> call(NotifyFamilyParams params) {
    return _repository.notifyFamily(
      petId: params.petId,
      message: params.message,
    );
  }
}
