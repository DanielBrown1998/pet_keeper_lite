import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/pet_model.dart';

/// Contract for pet data source (Firestore + Storage)
abstract class PetRemoteDataSource {
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

class PetRemoteDataSourceImpl implements PetRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  PetRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  }) : _firestore = firestore,
       _storage = storage;

  @override
  Stream<List<PetModel>> watchPets(String familyCode) {
    return _firestore
        .collection('pets')
        .where('familyCode', isEqualTo: familyCode)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => PetModel.fromFirestore(doc)).toList(),
        );
  }

  @override
  Future<PetModel?> getPet(String petId) async {
    final doc = await _firestore.collection('pets').doc(petId).get();
    if (!doc.exists) return null;
    return PetModel.fromFirestore(doc);
  }

  @override
  Future<void> createPet(PetModel pet) {
    return _firestore.collection('pets').doc(pet.id).set(pet.toFirestore());
  }

  @override
  Future<void> updatePet(PetModel pet) {
    return _firestore.collection('pets').doc(pet.id).update(pet.toFirestore());
  }

  @override
  Future<void> deletePet(String petId) {
    return _firestore.collection('pets').doc(petId).delete();
  }

  @override
  Future<String> uploadPhoto(String petId, File photo) async {
    final ref = _storage.ref('pet_photos/$petId.jpg');
    await ref.putFile(photo);
    final url = await ref.getDownloadURL();
    await _firestore.collection('pets').doc(petId).update({'photoUrl': url});
    return url;
  }

  @override
  Future<void> deletePhoto(String petId) async {
    try {
      await _storage.ref('pet_photos/$petId.jpg').delete();
    } catch (_) {
      // Photo might not exist, ignore
    }
  }

  @override
  Future<void> deleteTasksForPet(String petId) async {
    final tasksSnapshot = await _firestore
        .collection('pet_tasks')
        .where('petId', isEqualTo: petId)
        .get();

    for (final doc in tasksSnapshot.docs) {
      await doc.reference.delete();
    }
  }
}
