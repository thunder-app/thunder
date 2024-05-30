import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/utils/media/image.dart';

/// The Media class represents information for a given media source.
class Media {
  Media({
    this.thumbnailUrl,
    this.mediaUrl,
    this.originalUrl,
    this.width,
    this.height,
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

  /// Indicates the type of media it holds
  MediaType mediaType;

  /// Gets the full-size image URL, if any
  String? get imageUrl => isImageUrl(mediaUrl ?? '') ? mediaUrl : thumbnailUrl;

  @override
  String toString() {
    return '''Media { thumbnailUrl: $thumbnailUrl, mediaUrl: $mediaUrl, originalUrl: $originalUrl, width: $width, height: $height, type: $mediaType }''';
  }
}
