import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/pet_model.dart';
import 'pet_source.dart';

class PetSourceImpl implements PetSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  PetSourceImpl({
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
