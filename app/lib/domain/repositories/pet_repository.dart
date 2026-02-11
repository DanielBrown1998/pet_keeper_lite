import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/pet_entity.dart';

abstract class PetRepository {
  Stream<List<PetEntity>> watchPets(String familyCode);
  Future<Either<Failure, PetEntity>> getPet(String petId);
  Future<Either<Failure, PetEntity>> createPet(PetEntity pet);
  Future<Either<Failure, PetEntity>> updatePet(PetEntity pet);
  Future<Either<Failure, void>> deletePet(String petId);
  Future<Either<Failure, String>> uploadPetPhoto(String petId, File photo);
}
