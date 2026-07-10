/// Result of parsing a link, containing the extracted value and source instance.
class ParsedLink {
  /// The extracted value (community name, username, or ID as string)
  final String value;

  /// The source instance from the URL
  final String instance;

  const ParsedLink({required this.value, required this.instance});

  /// Returns the value in qualified format: value@instance
  String get qualified => '$value@$instance';

  @override
  String toString() => 'ParsedLink(value: $value, instance: $instance)';

  @override
  bool operator ==(Object other) => identical(this, other) || other is ParsedLink && runtimeType == other.runtimeType && value == other.value && instance == other.instance;

  @override
  int get hashCode => value.hashCode ^ instance.hashCode;
}
