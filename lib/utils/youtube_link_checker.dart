bool? isYouTubeLink(String? url) {
  if (url == null) {
    return null;
  }

  RegExp regExp = RegExp(r'^https?://(?:www\.)?youtube\.com/(?:[^/]+/u/\d+/|embed/|v/|watch\?v=|watch\?.+&v=|)([^"&?/\s]{11})');

  return regExp.hasMatch(url);
}
