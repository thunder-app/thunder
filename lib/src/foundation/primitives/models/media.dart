import 'package:thunder/src/foundation/primitives/enums/media_type.dart';

/// The Media class represents information for a given media source.
class Media {
  Media({
    this.thumbnailUrl,
    this.mediaUrl,
    this.originalUrl,
    this.width,
    this.height,
    this.nsfw = false,
    required this.mediaType,
  });

  /// The original external URL of the post
  String? originalUrl;

  /// The thumbnail URL of the media
  String? thumbnailUrl;

  /// The actual URL of the media source
  String? mediaUrl;

  /// The width of the media source
  double? width;

  /// The height of the media source
  double? height;

  /// Indicates whether the media is NSFW
  bool nsfw;

  /// Indicates the type of media it holds
  MediaType mediaType;

  /// Includes an alternative text-based description of the image
  String? altText;

  /// The content type of the media
  String? contentType;

  /// Gets the full-size image URL, if any
  String? get imageUrl => _isImageUrl(mediaUrl ?? '') ? mediaUrl : thumbnailUrl;

  @override
  String toString() {
    return '''
      Media {
        type: $mediaType,
        originalUrl: $originalUrl,
        thumbnailUrl: $thumbnailUrl,
        mediaUrl: $mediaUrl,
        width: $width,
        height: $height,
        nsfw: $nsfw,
        contentType: $contentType,
      }
      ''';
  }
}

bool _isImageUrl(String url) {
  final imageExtensions = <String>[
    '.png',
    '.jpg',
    '.jpeg',
    '.gif',
    '.bmp',
    '.webp',
    '.avif',
    '@jpeg',
  ];

  if (url.contains('/image_proxy')) return true;

  final uri = Uri.tryParse(url);
  if (uri == null) return false;

  final path = uri.path.toLowerCase();
  return imageExtensions.any(path.endsWith);
}
