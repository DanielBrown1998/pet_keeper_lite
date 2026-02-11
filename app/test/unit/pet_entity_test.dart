import 'package:app/domain/entities/pet_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PetEntity', () {
    test('should create PetEntity with required fields', () {
      final pet = PetEntity(
        id: '123',
        familyCode: 'FAMILY01',
        name: 'Rex',
        species: 'dog',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(pet.id, '123');
      expect(pet.familyCode, 'FAMILY01');
      expect(pet.name, 'Rex');
      expect(pet.species, 'dog');
      expect(pet.birthDate, isNull);
      expect(pet.weightKg, isNull);
      expect(pet.photoUrl, isNull);
    });

    test('should create PetEntity with all fields', () {
      final pet = PetEntity(
        id: '123',
        familyCode: 'FAMILY01',
        name: 'Rex',
        species: 'dog',
        birthDate: DateTime(2020, 5, 15),
        weightKg: 12.5,
        photoUrl: 'https://example.com/photo.jpg',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(pet.birthDate, DateTime(2020, 5, 15));
      expect(pet.weightKg, 12.5);
      expect(pet.photoUrl, 'https://example.com/photo.jpg');
    });

    test('copyWith should update specific fields', () {
      final pet = PetEntity(
        id: '123',
        familyCode: 'FAMILY01',
        name: 'Rex',
        species: 'dog',
        createdAt: DateTime(2024, 1, 1),
      );

      final updatedPet = pet.copyWith(name: 'Max', weightKg: 15.0);

      expect(updatedPet.id, '123');
      expect(updatedPet.name, 'Max');
      expect(updatedPet.weightKg, 15.0);
      expect(updatedPet.familyCode, 'FAMILY01');
    });

    test('two entities with same values should be equal', () {
      final pet1 = PetEntity(
        id: '123',
        familyCode: 'FAMILY01',
        name: 'Rex',
        species: 'dog',
        createdAt: DateTime(2024, 1, 1),
      );

      final pet2 = PetEntity(
        id: '123',
        familyCode: 'FAMILY01',
        name: 'Rex',
        species: 'dog',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(pet1, equals(pet2));
    });

    test('two entities with different values should not be equal', () {
      final pet1 = PetEntity(
        id: '123',
        familyCode: 'FAMILY01',
        name: 'Rex',
        species: 'dog',
        createdAt: DateTime(2024, 1, 1),
      );

      final pet2 = PetEntity(
        id: '456',
        familyCode: 'FAMILY01',
        name: 'Max',
        species: 'cat',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(pet1, isNot(equals(pet2)));
    });
  });
}
