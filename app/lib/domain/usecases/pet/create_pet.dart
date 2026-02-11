import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/pet_entity.dart';
import '../../repositories/pet_repository.dart';

class CreatePetParams {
  final PetEntity pet;
  final File? photo;

  const CreatePetParams({required this.pet, this.photo});
}

class CreatePet implements UseCase<PetEntity, CreatePetParams> {
  final PetRepository _repository;

  CreatePet(this._repository);

  @override
  Future<Either<Failure, PetEntity>> call(CreatePetParams params) async {
    final result = await _repository.createPet(params.pet);

    return result.fold((failure) => Left(failure), (pet) async {
      if (params.photo != null) {
        final photoResult = await _repository.uploadPetPhoto(
          pet.id,
          params.photo!,
        );
        return photoResult.fold(
          (failure) => Right(pet), // Pet created but photo failed
          (photoUrl) => Right(pet.copyWith(photoUrl: photoUrl)),
        );
      }
      return Right(pet);
    });
  }
}
