import 'dart:io';

import '../models/pet_model.dart';

/// Contract for pet data source (Firestore + Storage)
abstract class PetSource {
  /// Watch pets for a family code (real-time stream)
  Stream<List<PetModel>> watchPets(String familyCode);

  /// Get a single pet by ID
  Future<PetModel?> getPet(String petId);

  /// Create a new pet
  Future<void> createPet(PetModel pet);

  /// Update an existing pet
  Future<void> updatePet(PetModel pet);

  /// Delete a pet
  Future<void> deletePet(String petId);

  /// Upload pet photo and return download URL
  Future<String> uploadPhoto(String petId, File photo);

  /// Delete pet photo from storage
  Future<void> deletePhoto(String petId);

  /// Delete all tasks associated with a pet
  Future<void> deleteTasksForPet(String petId);
}
