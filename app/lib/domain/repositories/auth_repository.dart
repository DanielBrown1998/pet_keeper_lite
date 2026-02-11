import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  Future<UserEntity?> get currentUser;

  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  Future<Either<Failure, UserEntity>> signInWithGoogle();

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, void>> updateUserProfile({
    String? displayName,
    String? familyCode,
  });

  Future<Either<Failure, void>> updateFcmToken(String token);

  Future<Either<Failure, UserEntity>> getUserData(String uid);
}
