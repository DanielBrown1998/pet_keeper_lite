import 'package:flutter/material.dart';

/// Enum representing all supported pet species.
/// Use this instead of raw strings to ensure data consistency.
enum PetSpecies {
  dog('dog', 'Cachorro', '🐕', Icons.pets),
  cat('cat', 'Gato', '🐈', Icons.pets),
  bird('bird', 'Pássaro', '🐦', Icons.flutter_dash),
  fish('fish', 'Peixe', '🐟', Icons.water),
  rabbit('rabbit', 'Coelho', '🐰', Icons.pets),
  hamster('hamster', 'Hamster', '🐹', Icons.pets),
  other('other', 'Outro', '🐾', Icons.pets);

  const PetSpecies(this.value, this.displayName, this.emoji, this.icon);

  /// The value stored in the database
  final String value;

  /// The localized display name (Portuguese)
  final String displayName;

  /// Emoji representation for UI
  final String emoji;

  /// Icon representation for UI
  final IconData icon;

  /// Get display name with emoji
  String get displayNameWithEmoji => '$emoji $displayName';

  /// Convert from database string value to enum
  /// Returns [PetSpecies.other] if value is not recognized
  static PetSpecies fromValue(String? value) {
    if (value == null) return PetSpecies.other;
    return PetSpecies.values.firstWhere(
      (species) => species.value == value.toLowerCase(),
      orElse: () => PetSpecies.other,
    );
  }

  /// Convert from enum to database string value
  String toValue() => value;

  /// Get all species as a list of values (for dropdowns, etc.)
  static List<PetSpecies> get all => PetSpecies.values;
}
