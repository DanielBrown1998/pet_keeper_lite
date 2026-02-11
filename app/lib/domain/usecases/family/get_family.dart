import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/family_entity.dart';
import '../../repositories/family_repository.dart';

class GetFamily implements UseCase<FamilyEntity?, String> {
  final FamilyRepository _repository;

  GetFamily(this._repository);

  @override
  Future<Either<Failure, FamilyEntity?>> call(String familyCode) {
    return _repository.getFamily(familyCode);
  }
}
