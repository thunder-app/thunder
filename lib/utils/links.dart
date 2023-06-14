import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class LinkInfo {
  String? imageURL;
  String? title;

  LinkInfo({this.imageURL, this.title});
}

Future<LinkInfo> getLinkInfo(String url) async {
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final metatags = document.getElementsByTagName('meta');

      String imageURL = '';
      String title = '';

      for (final metatag in metatags) {
        final property = metatag.attributes['property'];
        final content = metatag.attributes['content'];

        if (property == 'og:image') {
          imageURL = content ?? '';
        } else if (property == 'og:title') {
          title = content ?? '';
        }
      }

      return LinkInfo(imageURL: imageURL, title: title);
    } else {
      throw Exception('Unable to fetch link information');
    }
  } catch (e) {
    return LinkInfo();
  }
}
