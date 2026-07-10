import 'package:thunder/src/core/domain/domain.dart';

/// User-selected options for the advanced share sheet.
class AdvancedShareSheetOptions {
  AdvancedShareSheetOptions({
    this.includePostLink = true,
    this.includeExternalLink = false,
    this.includeImage = true,
    this.includeText = false,
    this.includeTitle = false,
    this.includeCommnity = false,
  });

  /// Whether to include the post link in the share sheet.
  bool includePostLink;

  /// Whether to include the external link in the share sheet.
  bool includeExternalLink;

  /// Whether to include the image in the share sheet.
  bool includeImage;

  /// Whether to include the text in the share sheet.
  bool includeText;

  /// Whether to include the title in the share sheet.
  bool includeTitle;

  /// Whether to include the community in the share sheet.
  bool includeCommnity;

  AdvancedShareSheetOptions copy() => AdvancedShareSheetOptions(
        includePostLink: includePostLink,
        includeExternalLink: includeExternalLink,
        includeImage: includeImage,
        includeText: includeText,
        includeTitle: includeTitle,
        includeCommnity: includeCommnity,
      );

  Map<String, dynamic> toJson() => {
        'includePostLink': includePostLink,
        'includeExternalLink': includeExternalLink,
        'includeImage': includeImage,
        'includeText': includeText,
        'includeTitle': includeTitle,
        'includeCommnity': includeCommnity,
      };

  static AdvancedShareSheetOptions fromJson(Map<String, dynamic> json) {
    final defaults = AdvancedShareSheetOptions();

    return AdvancedShareSheetOptions(
      includePostLink: _boolOrDefault(json['includePostLink'], defaults.includePostLink),
      includeExternalLink: _boolOrDefault(json['includeExternalLink'], defaults.includeExternalLink),
      includeImage: _boolOrDefault(json['includeImage'], defaults.includeImage),
      includeText: _boolOrDefault(json['includeText'], defaults.includeText),
      includeTitle: _boolOrDefault(json['includeTitle'], defaults.includeTitle),
      includeCommnity: _boolOrDefault(json['includeCommnity'], defaults.includeCommnity),
    );
  }

  static bool _boolOrDefault(Object? value, bool defaultValue) => value is bool ? value : defaultValue;
}

Media? advancedSharePrimaryMedia(ThunderPost post) => post.media.isEmpty ? null : post.media.first;

String? advancedShareThumbnailUrl(ThunderPost post) {
  final thumbnailUrl = advancedSharePrimaryMedia(post)?.thumbnailUrl;
  return thumbnailUrl?.isNotEmpty == true ? thumbnailUrl : null;
}

String? advancedShareExternalLink(ThunderPost post) {
  final media = advancedSharePrimaryMedia(post);
  final originalUrl = media?.originalUrl;
  if (media == null || media.mediaType == MediaType.text || originalUrl?.isNotEmpty != true) return null;

  return originalUrl;
}

bool advancedShareHasImage(ThunderPost post) => advancedShareThumbnailUrl(post) != null;

bool advancedShareHasText(ThunderPost post) => post.body?.isNotEmpty == true;

bool advancedShareHasExternalLink(ThunderPost post) => advancedShareExternalLink(post) != null;

bool advancedShareCanShare(AdvancedShareSheetOptions options, ThunderPost post) {
  return options.includePostLink || (options.includeExternalLink && advancedShareHasExternalLink(post)) || advancedShareCanShareImage(options, post);
}

bool advancedShareCanShareImage(AdvancedShareSheetOptions options, ThunderPost post) {
  return (options.includeImage && advancedShareHasImage(post)) || advancedShareIsImageCustomized(options, post);
}

bool advancedShareIsImageCustomized(AdvancedShareSheetOptions options, ThunderPost post) {
  return options.includeTitle || (options.includeCommnity && post.community?.actorId.isNotEmpty == true) || (options.includeText && advancedShareHasText(post));
}

String? advancedShareText(AdvancedShareSheetOptions options, ThunderPost post) {
  final parts = [
    if (options.includePostLink) post.apId,
    if (options.includeExternalLink) advancedShareExternalLink(post),
  ].whereType<String>().toList();

  return parts.isEmpty ? null : parts.join('\n');
}
