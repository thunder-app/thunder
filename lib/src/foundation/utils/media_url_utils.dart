const List<String> imageExtensions = <String>['.png', '.jpg', '.jpeg', '.gif', '.bmp', '.webp', '.avif', '@jpeg'];

/// Extracts the target URL from known image proxy services.
/// Currently supports:
/// - `image_proxy` with a `url` query parameter
/// - DuckDuckGo's `external-content.duckduckgo.com` with a `u` query parameter
String? extractProxyTargetUrl(Uri uri) {
  final urlTarget = uri.queryParameters['url'];
  if (uri.path.contains('/image_proxy') && urlTarget?.isNotEmpty == true) {
    return urlTarget;
  }

  final duckDuckGoTarget = uri.queryParameters['u'];
  if (uri.host == 'external-content.duckduckgo.com' && uri.path.startsWith('/iu') && duckDuckGoTarget?.isNotEmpty == true) {
    return duckDuckGoTarget;
  }

  return null;
}

/// Resolves the original image URL by recursively extracting proxy targets until no more proxies are found.
String resolveProxyImageUrl(String url) {
  String currentUrl = url;

  while (true) {
    final uri = Uri.tryParse(currentUrl);
    if (uri == null) return currentUrl;

    final proxyTargetUrl = extractProxyTargetUrl(uri);
    if (proxyTargetUrl == null) return currentUrl;

    final parsedUri = Uri.tryParse(proxyTargetUrl);
    if (parsedUri == null) return currentUrl;

    currentUrl = parsedUri.toString();
  }
}

/// Checks if the given URL is a supported image URL, either directly or through a proxy.
bool isImageProxyUrlResolved(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;

  return extractProxyTargetUrl(uri) != null;
}

/// Checks if the URL has a supported image file extension.
bool hasImageFileExtension(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;

  final path = uri.path.toLowerCase();
  return imageExtensions.any(path.endsWith);
}

/// Determines if the given URL is a supported image URL, either directly or through a proxy.
bool isSupportedImageUrl(String url) {
  if (isImageProxyUrlResolved(url)) return true;
  return hasImageFileExtension(resolveProxyImageUrl(url));
}
