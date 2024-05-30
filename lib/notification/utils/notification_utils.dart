// This Regex should match HTML img tags in the following formats, where the alt text is placed in Group 2
// <img src="URL" />
// <img alt="a" src="URL" />
// <img alt="" src="URL" />
// <img src="URL" alt="" />
// <img src="URL" alt="a" />
//
// See: https://regex101.com/r/rSMP3Z/1
RegExp imgTag = RegExp(r'<img\s+([^>]*\s)?alt="([^"]*)"(?:\s[^>]*)?\/>|<img\s+([^>]*?)\/>');

/// Removes `img` tags from HTML content and replaces them with an italicize version of their alt text, or just the word "image".
String cleanImagesFromHtml(String htmlContent) {
  return htmlContent.replaceAllMapped(imgTag, (match) {
    if (match.group(2)?.isNotEmpty == true) {
      return '<i>${match.group(2)}</i>';
    }
    return '<i>image</i>';
  });
}
