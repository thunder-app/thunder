import 'package:equatable/equatable.dart';

/// A class that holds metadata about a link.
class ThunderLinkMetadata extends Equatable {
  /// The URL of the link.
  final String url;

  /// The title of the link.
  final String? title;

  /// The description of the link.
  final String? description;

  /// The image URL of the link.
  final String? imageUrl;

  const ThunderLinkMetadata({required this.url, this.title, this.description, this.imageUrl});

  /// Whether the link has content.
  bool get hasContent => title != null || description != null || imageUrl != null;

  /// Creates a new ThunderLinkMetadata from a Lemmy site metadata.
  factory ThunderLinkMetadata.fromLemmySiteMetadata(Map<String, dynamic> metadata, {required String url}) {
    return ThunderLinkMetadata(url: url, title: _stringOrNull(metadata['title']), description: _stringOrNull(metadata['description']), imageUrl: _stringOrNull(metadata['image']));
  }

  /// Creates a new ThunderLinkMetadata from a PieFed site metadata.
  factory ThunderLinkMetadata.fromPiefedSiteMetadata(Map<String, dynamic> metadata, {required String url}) {
    return ThunderLinkMetadata(url: url, title: _stringOrNull(metadata['title']), description: _stringOrNull(metadata['description']), imageUrl: _stringOrNull(metadata['image']));
  }

  static String? _stringOrNull(dynamic value) {
    if (value is! String) return null;

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  List<Object?> get props => [url, title, description, imageUrl];
}
