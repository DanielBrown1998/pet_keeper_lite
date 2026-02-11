import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/family_entity.dart';

class FamilyModel extends FamilyEntity {
  const FamilyModel({
    required super.familyCode,
    required super.createdAt,
    required super.ownerUid,
  });

  factory FamilyModel.fromEntity(FamilyEntity entity) {
    return FamilyModel(
      familyCode: entity.familyCode,
      createdAt: entity.createdAt,
      ownerUid: entity.ownerUid,
    );
  }

  factory FamilyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Family document data is null');
    }
    return FamilyModel(
      familyCode: doc.id,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      ownerUid: data['ownerUid'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'createdAt': Timestamp.fromDate(createdAt), 'ownerUid': ownerUid};
  }
}
