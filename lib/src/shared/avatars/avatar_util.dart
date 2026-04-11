/// Builds an avatar image URL from a source URL with optional thumbnail size and format.
///
/// The thumbnail size and format are only available on Lemmy instances using pictrs.
String? generateAvatarImageUrl(String? url, {int? thumbnailSize, String? format}) {
  if (url == null) return null;

  final uri = Uri.parse(url);
  if (!uri.path.contains('/pictrs/image/')) return uri.toString();

  final queryParameters = <String, String>{};

  if (thumbnailSize != null) queryParameters['thumbnail'] = thumbnailSize.toString();
  if (format != null) queryParameters['format'] = format;

  if (queryParameters.isNotEmpty) return Uri.https(uri.host, uri.path, queryParameters).toString();
  return uri.toString();
}
