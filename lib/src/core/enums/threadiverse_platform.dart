enum ThreadiversePlatform {
  lemmy,
  piefed;

  /// The maximum password length for the current platform. Lemmy restricts passwords to 60 characters, PieFed to 128 characters.
  int get maxPasswordLength => switch (this) {
        ThreadiversePlatform.lemmy => 60,
        ThreadiversePlatform.piefed => 128,
      };

  /// Converts a string value to ThreadiversePlatform enum
  static ThreadiversePlatform? fromString(String? value) {
    if (value == null) return null;
    try {
      return ThreadiversePlatform.values.firstWhere((platform) => platform.name == value);
    } catch (e) {
      return null;
    }
  }

  /// The name of the platform, formatted for display
  String get displayName => switch (this) {
        ThreadiversePlatform.lemmy => 'Lemmy',
        ThreadiversePlatform.piefed => 'PieFed',
      };

  /// Converts ThreadiversePlatform enum to string
  String? toStringValue() => name;
}
