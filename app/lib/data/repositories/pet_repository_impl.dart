import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/pet_entity.dart';
import '../../domain/repositories/pet_repository.dart';
import '../models/pet_model.dart';
import '../sources/pet_source.dart';

class PetRepositoryImpl implements PetRepository {
  final PetSource _petSource;

  PetRepositoryImpl({required PetSource petSource}) : _petSource = petSource;

  @override
  Stream<List<PetEntity>> watchPets(String familyCode) {
    return _petSource
        .watchPets(familyCode)
        .map((models) => models.map((model) => model as PetEntity).toList());
  }

  @override
  Future<Either<Failure, PetEntity>> getPet(String petId) async {
    try {
      final pet = await _petSource.getPet(petId);
      if (pet == null) {
        return const Left(ServerFailure('Pet não encontrado'));
      }
      return Right(pet);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PetEntity>> createPet(PetEntity pet) async {
    try {
      final petModel = PetModel.fromEntity(pet);
      await _petSource.createPet(petModel);
      return Right(petModel);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PetEntity>> updatePet(PetEntity pet) async {
    try {
      final petModel = PetModel.fromEntity(pet);
      await _petSource.updatePet(petModel);
      return Right(petModel);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePet(String petId) async {
    try {
      await _petSource.deletePet(petId);
      await _petSource.deletePhoto(petId);
      await _petSource.deleteTasksForPet(petId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadPetPhoto(
    String petId,
    File photo,
  ) async {
    try {
      final url = await _petSource.uploadPhoto(petId, photo);
      return Right(url);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }
}
