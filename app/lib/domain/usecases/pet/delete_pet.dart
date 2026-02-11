import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/pet_repository.dart';

class DeletePet implements UseCase<void, String> {
  final PetRepository _repository;

  DeletePet(this._repository);

  @override
  Future<Either<Failure, void>> call(String petId) {
    return _repository.deletePet(petId);
  }
}
