import 'package:equatable/equatable.dart';

class FamilyEntity extends Equatable {
  final String familyCode;
  final DateTime createdAt;
  final String ownerUid;

  const FamilyEntity({
    required this.familyCode,
    required this.createdAt,
    required this.ownerUid,
  });

  @override
  List<Object?> get props => [familyCode, createdAt, ownerUid];
}
