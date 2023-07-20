import 'package:flutter/material.dart';

import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:url_launcher/url_launcher.dart' hide launch;

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

void openLink(BuildContext context,
    {required String url, bool openInExternalBrowser = false}) async {
  if (openInExternalBrowser) {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    launch(
      url,
      customTabsOption: CustomTabsOption(
        toolbarColor: Theme.of(context).canvasColor,
        enableUrlBarHiding: true,
        showPageTitle: true,
        enableDefaultShare: true,
        enableInstantApps: true,
      ),
      safariVCOption: SafariViewControllerOption(
        preferredBarTintColor: Theme.of(context).canvasColor,
        preferredControlTintColor:
            Theme.of(context).textTheme.titleLarge?.color ??
                Theme.of(context).primaryColor,
        barCollapsingEnabled: true,
      ),
    );
  }
}
