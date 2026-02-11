import 'package:equatable/equatable.dart';

class PetEntity extends Equatable {
  final String id;
  final String familyCode;
  final String name;
  final String species;
  final DateTime? birthDate;
  final double? weightKg;
  final String? photoUrl;
  final DateTime createdAt;

  const PetEntity({
    required this.id,
    required this.familyCode,
    required this.name,
    required this.species,
    this.birthDate,
    this.weightKg,
    this.photoUrl,
    required this.createdAt,
  });

  PetEntity copyWith({
    String? id,
    String? familyCode,
    String? name,
    String? species,
    DateTime? birthDate,
    double? weightKg,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return PetEntity(
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

  @override
  List<Object?> get props => [
    id,
    familyCode,
    name,
    species,
    birthDate,
    weightKg,
    photoUrl,
    createdAt,
  ];
}
