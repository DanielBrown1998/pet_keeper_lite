import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/family_entity.dart';
import '../../domain/repositories/family_repository.dart';
import '../models/family_model.dart';
import '../sources/auth_remote_data_source.dart';
import '../sources/family_remote_data_source.dart';

class FamilyRepositoryImpl implements FamilyRepository {
  final FamilyRemoteDataSource _familyRemoteDataSource;
  final AuthRemoteDataSource _authRemoteDataSource;

  FamilyRepositoryImpl({
    required FamilyRemoteDataSource familyRemoteDataSource,
    required AuthRemoteDataSource authRemoteDataSource,
  }) : _familyRemoteDataSource = familyRemoteDataSource,
       _authRemoteDataSource = authRemoteDataSource;

  @override
  Future<Either<Failure, FamilyEntity>> createFamily(String familyCode) async {
    try {
      final user = _authRemoteDataSource.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      final family = FamilyModel(
        familyCode: familyCode,
        createdAt: DateTime.now(),
        ownerUid: user.uid,
      );

      await _familyRemoteDataSource.createFamily(family);
      return Right(family);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FamilyEntity?>> getFamily(String familyCode) async {
    try {
      final family = await _familyRemoteDataSource.getFamily(familyCode);
      return Right(family);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> familyExists(String familyCode) async {
    try {
      final exists = await _familyRemoteDataSource.familyExists(familyCode);
      return Right(exists);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> joinFamily(String familyCode) async {
    try {
      final user = _authRemoteDataSource.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      // Update user's family code
      await _authRemoteDataSource.updateUserProfile(user.uid, {
        'familyCode': familyCode,
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
