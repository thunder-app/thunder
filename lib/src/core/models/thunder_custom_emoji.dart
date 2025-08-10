class ThunderCustomEmojiKeyword {
  /// The custom emoji ID this keyword belongs to.
  final int customEmojiId;

  /// The keyword for the custom emoji.
  final String keyword;

  ThunderCustomEmojiKeyword({
    required this.customEmojiId,
    required this.keyword,
  });

  factory ThunderCustomEmojiKeyword.fromLemmyKeyword(Map<String, dynamic> keyword) {
    return ThunderCustomEmojiKeyword(
      customEmojiId: keyword['custom_emoji_id'],
      keyword: keyword['keyword'],
    );
  }
}

class ThunderCustomEmoji {
  /// The custom emoji's ID.
  final int id;

  /// The custom emoji's local site ID.
  final int localSiteId;

  /// The custom emoji's shortcode.
  final String shortcode;

  /// The custom emoji's image URL.
  final String imageUrl;

  /// The custom emoji's alt text.
  final String altText;

  /// The custom emoji's category.
  final String category;

  /// The custom emoji's published date.
  final DateTime published;

  /// The custom emoji's updated date.
  final DateTime? updated;

  /// The custom emoji's keywords.
  final List<ThunderCustomEmojiKeyword> keywords;

  ThunderCustomEmoji({
    required this.id,
    required this.localSiteId,
    required this.shortcode,
    required this.imageUrl,
    required this.altText,
    required this.category,
    required this.published,
    this.updated,
    required this.keywords,
  });

  factory ThunderCustomEmoji.fromLemmyCustomEmoji(Map<String, dynamic> customEmojiData) {
    final customEmoji = customEmojiData['custom_emoji'];
    final keywordsList = customEmojiData['keywords'] as List<dynamic>? ?? [];

    return ThunderCustomEmoji(
      id: customEmoji['id'],
      localSiteId: customEmoji['local_site_id'],
      shortcode: customEmoji['shortcode'],
      imageUrl: customEmoji['image_url'],
      altText: customEmoji['alt_text'],
      category: customEmoji['category'],
      published: DateTime.parse(customEmoji['published']),
      updated: customEmoji['updated'] != null ? DateTime.parse(customEmoji['updated']) : null,
      keywords: keywordsList.map((k) => ThunderCustomEmojiKeyword.fromLemmyKeyword(k)).toList(),
    );
  }
}
