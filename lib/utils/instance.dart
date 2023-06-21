String? fetchInstanceNameFromUrl(String? url) {
  if (url == null) {
    return null;
  }

  final uri = Uri.parse(url);
  return uri.host;
}

String? generateCommunityInstanceUrl(String? url) {
  if (url == null) {
    return null;
  }

  final uri = Uri.parse(url);
  final communityName = uri.pathSegments[1];
  return '$communityName@${uri.host}';
}

String? checkLemmyInstanceUrl(String text) {
  if (text.contains('@')) return text;
  if (text.contains('/c/')) return generateCommunityInstanceUrl(text);
  return null;
}
