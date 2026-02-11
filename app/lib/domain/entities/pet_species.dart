/// Enum representing all supported pet species.
/// Use this instead of raw strings to ensure data consistency.
enum PetSpecies {
  dog('dog', 'Cachorro', '🐕'),
  cat('cat', 'Gato', '🐈'),
  bird('bird', 'Pássaro', '🐦'),
  fish('fish', 'Peixe', '🐟'),
  rabbit('rabbit', 'Coelho', '🐰'),
  hamster('hamster', 'Hamster', '🐹'),
  other('other', 'Outro', '🐾');

  const PetSpecies(this.value, this.displayName, this.emoji);

  /// The value stored in the database
  final String value;

  /// The localized display name (Portuguese)
  final String displayName;

  /// Emoji representation for UI
  final String emoji;

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
