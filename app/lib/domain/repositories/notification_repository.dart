import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

abstract class NotificationRepository {
  Future<Either<Failure, void>> notifyFamily({
    required String petId,
    required String message,
  });
  Future<Either<Failure, String?>> getToken();
  Future<Either<Failure, void>> requestPermission();
}
