import '../models/family_model.dart';

/// Contract for family data source (Firestore)
abstract class FamilySource {
  /// Get a family by code
  Future<FamilyModel?> getFamily(String familyCode);

  /// Create a new family
  Future<void> createFamily(FamilyModel family);

  /// Check if family exists
  Future<bool> familyExists(String familyCode);
}
