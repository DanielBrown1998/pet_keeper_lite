import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? familyCode;
  final List<String> fcmTokens;

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.familyCode,
    this.fcmTokens = const [],
  });

  UserEntity copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? familyCode,
    List<String>? fcmTokens,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      familyCode: familyCode ?? this.familyCode,
      fcmTokens: fcmTokens ?? this.fcmTokens,
    );
  }

  @override
  List<Object?> get props => [uid, email, displayName, familyCode, fcmTokens];
}
