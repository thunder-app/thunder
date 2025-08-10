class ThunderTagline {
  /// The tagline's ID.
  final int id;

  /// The tagline's local site ID.
  final int localSiteId;

  /// The tagline's content.
  final String content;

  /// The tagline's published date.
  final DateTime published;

  /// The tagline's updated date.
  final DateTime? updated;

  ThunderTagline({
    required this.id,
    required this.localSiteId,
    required this.content,
    required this.published,
    this.updated,
  });

  factory ThunderTagline.fromLemmyTagline(Map<String, dynamic> tagline) {
    return ThunderTagline(
      id: tagline['id'],
      localSiteId: tagline['local_site_id'],
      content: tagline['content'],
      published: DateTime.parse(tagline['published']),
      updated: tagline['updated'] != null ? DateTime.parse(tagline['updated']) : null,
    );
  }
}
