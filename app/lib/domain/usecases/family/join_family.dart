import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/family_entity.dart';
import '../../repositories/family_repository.dart';

class JoinFamily implements UseCase<FamilyEntity?, String> {
  final FamilyRepository _familyRepository;

  JoinFamily(this._familyRepository);

  @override
  Future<Either<Failure, FamilyEntity?>> call(String familyCode) async {
    // Check if family exists
    final existsResult = await _familyRepository.familyExists(familyCode);

    return existsResult.fold((failure) => Left(failure), (exists) async {
      if (!exists) {
        return const Left(ValidationFailure('Família não encontrada'));
      }

      // Join family
      final joinResult = await _familyRepository.joinFamily(familyCode);

      return joinResult.fold((failure) => Left(failure), (_) async {
        // Get family data
        final familyResult = await _familyRepository.getFamily(familyCode);
        return familyResult;
      });
    });
  }
}
