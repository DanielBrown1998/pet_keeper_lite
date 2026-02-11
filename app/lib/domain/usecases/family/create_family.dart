import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/family_entity.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/family_repository.dart';

class CreateFamily implements UseCase<FamilyEntity, String> {
  final FamilyRepository _familyRepository;
  final AuthRepository _authRepository;

  CreateFamily(this._familyRepository, this._authRepository);

  @override
  Future<Either<Failure, FamilyEntity>> call(String familyCode) async {
    // Check if family already exists
    final existsResult = await _familyRepository.familyExists(familyCode);

    return existsResult.fold((failure) => Left(failure), (exists) async {
      if (exists) {
        return const Left(
          ValidationFailure('Este código de família já existe'),
        );
      }

      // Create family
      final createResult = await _familyRepository.createFamily(familyCode);

      return createResult.fold((failure) => Left(failure), (family) async {
        // Update user's family code
        await _authRepository.updateUserProfile(familyCode: familyCode);
        return Right(family);
      });
    });
  }
}
