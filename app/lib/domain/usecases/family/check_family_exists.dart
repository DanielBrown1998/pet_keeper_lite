import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/family_repository.dart';

class CheckFamilyExists implements UseCase<bool, String> {
  final FamilyRepository _repository;

  CheckFamilyExists(this._repository);

  @override
  Future<Either<Failure, bool>> call(String familyCode) {
    return _repository.familyExists(familyCode);
  }
}
