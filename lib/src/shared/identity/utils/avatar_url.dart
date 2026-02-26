String? buildAvatarImageUrl(
  String? sourceUrl, {
  int? thumbnailSize,
  String? format,
}) {
  if (sourceUrl == null) return null;

  final queryParameters = <String, String>{};
  if (thumbnailSize != null) {
    queryParameters['thumbnail'] = thumbnailSize.toString();
  }
  if (format != null) {
    queryParameters['format'] = format;
  }

  final imageUri = Uri.parse(sourceUrl);

  if (imageUri.path.contains('/pictrs/image/') && queryParameters.isNotEmpty) {
    return Uri.https(imageUri.host, imageUri.path, queryParameters).toString();
  }

  return imageUri.toString();
}
