import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/pet_entity.dart';
import '../../domain/repositories/pet_repository.dart';
import '../models/pet_model.dart';
import '../sources/pet_remote_data_source.dart';

class PetRepositoryImpl implements PetRepository {
  final PetRemoteDataSource _petRemoteDataSource;

  PetRepositoryImpl({required PetRemoteDataSource petRemoteDataSource})
    : _petRemoteDataSource = petRemoteDataSource;

  @override
  Stream<List<PetEntity>> watchPets(String familyCode) {
    return _petRemoteDataSource
        .watchPets(familyCode)
        .map((models) => models.map((model) => model as PetEntity).toList());
  }

  @override
  Future<Either<Failure, PetEntity>> getPet(String petId) async {
    try {
      final pet = await _petRemoteDataSource.getPet(petId);
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
      await _petRemoteDataSource.createPet(petModel);
      return Right(petModel);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PetEntity>> updatePet(PetEntity pet) async {
    try {
      final petModel = PetModel.fromEntity(pet);
      await _petRemoteDataSource.updatePet(petModel);
      return Right(petModel);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePet(String petId) async {
    try {
      await _petRemoteDataSource.deletePet(petId);
      await _petRemoteDataSource.deletePhoto(petId);
      await _petRemoteDataSource.deleteTasksForPet(petId);
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
      final url = await _petRemoteDataSource.uploadPhoto(petId, photo);
      return Right(url);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }
}
