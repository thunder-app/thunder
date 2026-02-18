import 'package:intl/message_format.dart';

/// Resolves the best URL from markdown link text and target.
String resolveMarkdownLink(String text, String? url) {
  final parsedUri = Uri.tryParse(url ?? '') ?? Uri.tryParse(text);

  String parsedUrl = text;

  if (parsedUri != null && parsedUri.host.isNotEmpty) {
    parsedUrl = parsedUri.toString();
  } else {
    parsedUrl = url ?? '';
  }

  // The markdown link processor treats URLs with @ as emails and prepends
  // `mailto:`. If the displayed text does not include that prefix, remove it.
  if (parsedUrl.startsWith('mailto:') && !text.startsWith('mailto:')) {
    parsedUrl = parsedUrl.replaceFirst('mailto:', '');
  }

  return parsedUrl;
}

List<({String sourceName, String link})> generateAlternateSources(String link) {
  return _alternateSources.map((alternateSource) {
    return (sourceName: alternateSource.sourceName, link: alternateSource.template.format({'link': link}));
  }).toList();
}

final List<({String sourceName, MessageFormat template})> _alternateSources = [
  (sourceName: 'Archive Today', template: MessageFormat('https://archive.today/{link}')),
  (sourceName: 'Internet Archive', template: MessageFormat('https://web.archive.org/save/{link}')),
  (sourceName: 'Ground News', template: MessageFormat('https://ground.news/find?url={link}')),
];

/// Determines if a given URL is valid. The URL must have the `http` or
/// `https` scheme.
bool isValidUrl(String url) {
  final uri = Uri.tryParse(url);
  return uri != null && uri.hasAbsolutePath && uri.scheme.startsWith('http');
}
