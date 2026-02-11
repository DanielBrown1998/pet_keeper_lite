import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../sources/auth_remote_data_source.dart';
import '../sources/google_auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource;
  final GoogleAuthRemoteDataSource _googleAuthRemoteDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource authRemoteDataSource,
    required GoogleAuthRemoteDataSource googleAuthRemoteDataSource,
  }) : _authRemoteDataSource = authRemoteDataSource,
       _googleAuthRemoteDataSource = googleAuthRemoteDataSource;

  @override
  Stream<UserEntity?> get authStateChanges {
    return _authRemoteDataSource.authStateChanges.asyncMap((user) async {
      if (user == null) return null;
      try {
        final userData = await _authRemoteDataSource.getUserData(user.uid);
        if (userData != null) {
          return userData;
        }
        return UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
        );
      } catch (e) {
        return UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
        );
      }
    });
  }

  @override
  Future<UserEntity?> get currentUser async {
    final user = _authRemoteDataSource.currentUser;
    if (user == null) return null;
    try {
      final userData = await _authRemoteDataSource.getUserData(user.uid);
      if (userData != null) {
        return userData;
      }
      return UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
      );
    } catch (e) {
      return UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _authRemoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return const Left(AuthFailure('Falha ao fazer login'));
      }

      final userData = await _authRemoteDataSource.getUserData(user.uid);
      if (userData != null) {
        return Right(userData);
      }

      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
      );
      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e.code)));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _authRemoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return const Left(AuthFailure('Falha ao criar conta'));
      }

      if (displayName != null) {
        await _authRemoteDataSource.updateDisplayName(displayName);
      }

      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: displayName,
      );

      await _authRemoteDataSource.saveUserData(userModel);

      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e.code)));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final credential = await _googleAuthRemoteDataSource.signIn();
      if (credential == null) {
        return const Left(AuthFailure('Login com Google cancelado'));
      }

      final userCredential = await _authRemoteDataSource.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user == null) {
        return const Left(AuthFailure('Falha ao fazer login com Google'));
      }

      final userData = await _authRemoteDataSource.getUserData(user.uid);
      if (userData != null) {
        return Right(userData);
      }

      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
      );

      await _authRemoteDataSource.saveUserData(userModel);

      return Right(userModel);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await Future.wait([
        _authRemoteDataSource.signOut(),
        _googleAuthRemoteDataSource.signOut(),
      ]);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile({
    String? displayName,
    String? familyCode,
  }) async {
    try {
      final user = _authRemoteDataSource.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      final updates = <String, dynamic>{};
      if (displayName != null) {
        updates['displayName'] = displayName;
        await _authRemoteDataSource.updateDisplayName(displayName);
      }
      if (familyCode != null) {
        updates['familyCode'] = familyCode;
      }

      if (updates.isNotEmpty) {
        await _authRemoteDataSource.updateUserProfile(user.uid, updates);
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateFcmToken(String token) async {
    try {
      final user = _authRemoteDataSource.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      await _authRemoteDataSource.addFcmToken(user.uid, token);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserData(String uid) async {
    try {
      final userData = await _authRemoteDataSource.getUserData(uid);
      if (userData == null) {
        return const Left(ServerFailure('Usuário não encontrado'));
      }
      return Right(userData);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'email-already-in-use':
        return 'Este email já está em uso';
      case 'weak-password':
        return 'Senha muito fraca';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-disabled':
        return 'Usuário desabilitado';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde';
      default:
        return 'Erro de autenticação';
    }
  }
}
