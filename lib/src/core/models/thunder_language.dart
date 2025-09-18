class ThunderLanguage {
  /// The language's ID.
  final int id;

  /// The language's code.
  final String code;

  /// The language's name.
  final String name;

  ThunderLanguage({required this.id, required this.code, required this.name});

  factory ThunderLanguage.fromLemmyLanguage(Map<String, dynamic> language) {
    return ThunderLanguage(
      id: language['id'],
      code: language['code'],
      name: language['name'],
    );
  }

  factory ThunderLanguage.fromPiefedLanguage(Map<String, dynamic> language) {
    return ThunderLanguage(
      id: language['id'],
      code: language['code'],
      name: language['name'],
    );
  }
}
