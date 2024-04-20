bool? isYouTubeLink(String? url) {
  if (url == null) {
    return null;
  }

  RegExp regExp = RegExp(r'(?:https?://)?(?:www\.)?(?:youtube\.com(?:/[^/]+/.+/.+|\?.*v=|/v/)|youtu\.be/)([^"&?/\s]{11})');

  return regExp.hasMatch(url);
}
