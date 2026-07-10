import 'package:thunder/src/core/domain/enums/media_type.dart';
import 'package:thunder/src/core/utils/media_url_utils.dart';

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
  String? get imageUrl => isSupportedImageUrl(mediaUrl ?? '') ? mediaUrl : thumbnailUrl;

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
