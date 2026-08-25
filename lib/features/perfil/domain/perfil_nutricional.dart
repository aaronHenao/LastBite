class PerfilNutricional {
  const PerfilNutricional({
    this.userType = 'none',
    this.goal = 'none',
    this.dietaryType = 'omnivore',
    this.restrictions = const [],
    this.allergies = const [],
  });

  final String userType;
  final String goal;
  final String dietaryType;
  final List<String> restrictions;
  final List<String> allergies;

  bool get hasRecipePreferences =>
      dietaryType != 'omnivore' ||
      restrictions.isNotEmpty ||
      allergies.isNotEmpty ||
      userType == 'athlete' ||
      (userType == 'nutritional_plan' && goal != 'none');

  Map<String, dynamic> toMap() => {
    'userType': userType,
    'goal': goal,
    'dietaryType': dietaryType,
    'restrictions': restrictions,
    'allergies': allergies,
  };

  factory PerfilNutricional.fromMap(Map<String, dynamic> map) {
    return PerfilNutricional(
      userType: map['userType']?.toString() ?? 'none',
      goal: map['goal']?.toString() ?? 'none',
      dietaryType: map['dietaryType']?.toString() ?? 'omnivore',
      restrictions: _stringsFrom(map['restrictions']),
      allergies: _stringsFrom(map['allergies']),
    );
  }

  String get cacheKey {
    final values = [userType, goal, dietaryType, ...restrictions, ...allergies];
    return values.join('|');
  }

  PerfilNutricional copyWith({
    String? userType,
    String? goal,
    String? dietaryType,
    List<String>? restrictions,
    List<String>? allergies,
  }) {
    return PerfilNutricional(
      userType: userType ?? this.userType,
      goal: goal ?? this.goal,
      dietaryType: dietaryType ?? this.dietaryType,
      restrictions: restrictions ?? this.restrictions,
      allergies: allergies ?? this.allergies,
    );
  }

  static List<String> _stringsFrom(Object? value) {
    if (value is! List) return const [];
    return value
        .map((item) => item.toString().trim().toLowerCase())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
  }
}
