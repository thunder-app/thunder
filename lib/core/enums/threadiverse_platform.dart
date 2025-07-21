enum ThreadiversePlatform {
  lemmy,
  piefed;

  /// Converts a string value to ThreadiversePlatform enum
  static ThreadiversePlatform? fromString(String? value) {
    if (value == null) return null;
    try {
      return ThreadiversePlatform.values.firstWhere((platform) => platform.name == value);
    } catch (e) {
      return null;
    }
  }

  /// Converts ThreadiversePlatform enum to string
  String? toStringValue() => name;
}
