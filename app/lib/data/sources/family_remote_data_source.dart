import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/family_model.dart';

/// Contract for family data source (Firestore)
abstract class FamilyRemoteDataSource {
  /// Get a family by code
  Future<FamilyModel?> getFamily(String familyCode);

  /// Create a new family
  Future<void> createFamily(FamilyModel family);

  /// Check if family exists
  Future<bool> familyExists(String familyCode);
}

class FamilyRemoteDataSourceImpl implements FamilyRemoteDataSource {
  final FirebaseFirestore _firestore;

  FamilyRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<FamilyModel?> getFamily(String familyCode) async {
    final doc = await _firestore.collection('families').doc(familyCode).get();
    if (!doc.exists) return null;
    return FamilyModel.fromFirestore(doc);
  }

  @override
  Future<void> createFamily(FamilyModel family) {
    return _firestore
        .collection('families')
        .doc(family.familyCode)
        .set(family.toFirestore());
  }

  @override
  Future<bool> familyExists(String familyCode) async {
    final doc = await _firestore.collection('families').doc(familyCode).get();
    return doc.exists;
  }
}
