/// An uploaded media item owned by the current account.
class AccountMediaItem {
  /// The pictrs alias / filename used by the backend.
  final String alias;

  /// The URL that can be used to display the uploaded media.
  final String url;

  /// When this item was uploaded.
  final DateTime? uploadedAt;

  /// The post this image is a generated thumbnail for, when provided.
  final int? thumbnailForPostId;

  /// Delete token used by older pictrs-backed services.
  final String? deleteToken;

  const AccountMediaItem({required this.alias, required this.url, this.uploadedAt, this.thumbnailForPostId, this.deleteToken});
}
