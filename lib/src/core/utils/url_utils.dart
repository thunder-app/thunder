/// Determines if a given URL is valid. The URL must have the 'http' or 'https' scheme.
bool isValidUrl(String url) {
  final uri = Uri.tryParse(url);
  return uri != null && uri.hasAbsolutePath && uri.scheme.startsWith('http');
}
