import 'package:thunder/core/enums/media_type.dart';

/// The Media class represents information for a given media source.
class Media {
  Media({
    this.mediaUrl,
    this.originalUrl,
    this.width,
    this.height,
    this.mediaType,
  });

  /// The original URL of the media - this applies if the original URL of the media originates from a external link
  String? originalUrl;

  /// The URL indicates the source of the media
  String? mediaUrl;

  /// The width of the media source
  double? width;

  /// The height of the media source
  double? height;

  /// Indicates the type of media it holds
  MediaType? mediaType;

  @override
  String toString() {
    return '''Media { mediaUrl: $mediaUrl, originalUrl: $originalUrl, width: $width, height: $height, type: $mediaType }''';
  }
}
