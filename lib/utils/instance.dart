String? fetchInstanceNameFromUrl(String? url) {
  if (url == null) {
    return null;
  }

  final uri = Uri.parse(url);
  return uri.host;
}
