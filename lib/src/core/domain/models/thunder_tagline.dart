class ThunderTagline {
  /// The tagline's content.
  final String content;

  ThunderTagline({required this.content});

  factory ThunderTagline.fromLemmyTagline(Map<String, dynamic> tagline) {
    return ThunderTagline(content: tagline['content']);
  }
}
