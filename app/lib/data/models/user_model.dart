import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    super.displayName,
    super.familyCode,
    super.fcmTokens,
  });

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      familyCode: entity.familyCode,
      fcmTokens: entity.fcmTokens,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('User document data is null');
    }
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      familyCode: data['familyCode'],
      fcmTokens: List<String>.from(data['fcmTokens'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'familyCode': familyCode,
      'fcmTokens': fcmTokens,
    };
  }

  @override
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? familyCode,
    List<String>? fcmTokens,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      familyCode: familyCode ?? this.familyCode,
      fcmTokens: fcmTokens ?? this.fcmTokens,
    );
  }
}
