class ThunderBlockedUrl {
  /// The blocked URL's ID.
  final int id;

  /// The blocked URL.
  final String url;

  /// The blocked URL's published date.
  final DateTime published;

  /// The blocked URL's updated date.
  final DateTime? updated;

  ThunderBlockedUrl({
    required this.id,
    required this.url,
    required this.published,
    this.updated,
  });

  factory ThunderBlockedUrl.fromLemmyBlockedUrl(Map<String, dynamic> blockedUrl) {
    return ThunderBlockedUrl(
      id: blockedUrl['id'],
      url: blockedUrl['url'],
      published: DateTime.parse(blockedUrl['published']),
      updated: blockedUrl['updated'] != null ? DateTime.parse(blockedUrl['updated']) : null,
    );
  }
}
