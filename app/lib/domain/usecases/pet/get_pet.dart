import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/pet_entity.dart';
import '../../repositories/pet_repository.dart';

class GetPet implements UseCase<PetEntity, String> {
  final PetRepository _repository;

  GetPet(this._repository);

  @override
  Future<Either<Failure, PetEntity>> call(String petId) {
    return _repository.getPet(petId);
  }
}
