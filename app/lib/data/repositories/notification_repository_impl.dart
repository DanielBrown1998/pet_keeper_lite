import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/repositories/notification_repository.dart';
import '../sources/notification_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationSource _notificationSource;

  NotificationRepositoryImpl({required NotificationSource notificationSource})
    : _notificationSource = notificationSource;

  @override
  Future<Either<Failure, void>> notifyFamily({
    required String petId,
    required String message,
  }) async {
    try {
      await _notificationSource.notifyFamily(petId: petId, message: message);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> getToken() async {
    try {
      final token = await _notificationSource.getToken();
      return Right(token);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> requestPermission() async {
    try {
      await _notificationSource.requestPermission();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
