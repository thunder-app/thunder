import 'package:thunder/packages/ui/src/models/content/content_media_type.dart';

/// Generic media model used by content widgets.
class ContentMedia {
  ContentMedia({
    this.thumbnailUrl,
    this.mediaUrl,
    this.originalUrl,
    this.width,
    this.height,
    this.nsfw = false,
    required this.mediaType,
    this.altText,
    this.contentType,
  });

  /// The original external URL of the post.
  String? originalUrl;

  /// The thumbnail URL of the media.
  String? thumbnailUrl;

  /// The actual URL of the media source.
  String? mediaUrl;

  /// The width of the media source.
  double? width;

  /// The height of the media source.
  double? height;

  /// Indicates whether the media is NSFW.
  bool nsfw;

  /// Indicates the type of media it holds.
  ContentMediaType mediaType;

  /// Includes an alternative text-based description of the image.
  String? altText;

  /// The content type of the media.
  String? contentType;

  /// Gets the full-size image URL, if any.
  String? get imageUrl => _looksLikeImage(mediaUrl) ? mediaUrl : thumbnailUrl;

  bool _looksLikeImage(String? url) {
    if (url == null) return false;
    if (url.contains('/image_proxy')) return true;

    final lowerPath = (Uri.tryParse(url)?.path ?? url).toLowerCase();
    return lowerPath.endsWith('.png') ||
        lowerPath.endsWith('.jpg') ||
        lowerPath.endsWith('.jpeg') ||
        lowerPath.endsWith('.gif') ||
        lowerPath.endsWith('.bmp') ||
        lowerPath.endsWith('.webp') ||
        lowerPath.endsWith('.avif') ||
        lowerPath.endsWith('@jpeg');
  }
}
