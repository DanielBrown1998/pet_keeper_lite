import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/pet_entity.dart';

class PetModel extends PetEntity {
  const PetModel({
    required super.id,
    required super.familyCode,
    required super.name,
    required super.species,
    super.birthDate,
    super.weightKg,
    super.photoUrl,
    required super.createdAt,
  });

  factory PetModel.fromEntity(PetEntity entity) {
    return PetModel(
      id: entity.id,
      familyCode: entity.familyCode,
      name: entity.name,
      species: entity.species,
      birthDate: entity.birthDate,
      weightKg: entity.weightKg,
      photoUrl: entity.photoUrl,
      createdAt: entity.createdAt,
    );
  }

  factory PetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Pet document data is null');
    }
    return PetModel(
      id: doc.id,
      familyCode: data['familyCode'] ?? '',
      name: data['name'] ?? '',
      species: data['species'] ?? 'other',
      birthDate: data['birthDate'] != null
          ? (data['birthDate'] as Timestamp).toDate()
          : null,
      weightKg: data['weightKg']?.toDouble(),
      photoUrl: data['photoUrl'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'familyCode': familyCode,
      'name': name,
      'species': species,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'weightKg': weightKg,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  PetModel copyWith({
    String? id,
    String? familyCode,
    String? name,
    String? species,
    DateTime? birthDate,
    double? weightKg,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return PetModel(
      id: id ?? this.id,
      familyCode: familyCode ?? this.familyCode,
      name: name ?? this.name,
      species: species ?? this.species,
      birthDate: birthDate ?? this.birthDate,
      weightKg: weightKg ?? this.weightKg,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
