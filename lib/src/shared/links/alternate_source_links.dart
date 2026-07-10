import 'package:intl/message_format.dart';

List<({String sourceName, String link})> generateAlternateSources(String link) {
  return _alternateSources.map((alternateSource) {
    return (sourceName: alternateSource.sourceName, link: alternateSource.template.format({'link': link}));
  }).toList();
}

List<({String sourceName, MessageFormat template})> _alternateSources = [
  (sourceName: 'Internet Archive', template: MessageFormat('https://web.archive.org/save/{link}')),
  (sourceName: 'Ground News', template: MessageFormat('https://ground.news/find?url={link}')),
];
