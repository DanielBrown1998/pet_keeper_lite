import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/pet_entity.dart';
import '../../repositories/pet_repository.dart';

class UpdatePetParams {
  final PetEntity pet;
  final File? photo;

  const UpdatePetParams({required this.pet, this.photo});
}

class UpdatePet implements UseCase<PetEntity, UpdatePetParams> {
  final PetRepository _repository;

  UpdatePet(this._repository);

  @override
  Future<Either<Failure, PetEntity>> call(UpdatePetParams params) async {
    final result = await _repository.updatePet(params.pet);

    return result.fold((failure) => Left(failure), (pet) async {
      if (params.photo != null) {
        final photoResult = await _repository.uploadPetPhoto(
          pet.id,
          params.photo!,
        );
        return photoResult.fold(
          (failure) => Right(pet), // Pet updated but photo failed
          (photoUrl) => Right(pet.copyWith(photoUrl: photoUrl)),
        );
      }
      return Right(pet);
    });
  }
}
