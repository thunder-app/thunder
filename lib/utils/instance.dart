import 'package:lemmy_api_client/v3.dart';

String? fetchInstanceNameFromUrl(String? url) {
  if (url == null) {
    return null;
  }

  final uri = Uri.parse(url);
  return uri.host;
}

String? generateCommunityInstanceUrl(String? url) {
  if (url == null) {
    return null;
  }

  final uri = Uri.parse(url);
  final communityName = uri.pathSegments[1];
  return '$communityName@${uri.host}';
}

String? checkLemmyInstanceUrl(String text) {
  if (text.contains('@')) return text;
  if (text.contains('/c/')) return generateCommunityInstanceUrl(text);
  return null;
}

Future<String?> getInstanceIcon(String? url) async {
  if (url?.isEmpty ?? true) {
    return null;
  }

  try {
    final site = await LemmyApiV3(url!)
        .run(const GetSite())
        .timeout(const Duration(seconds: 5));
    return site.siteView?.site.icon;
  } catch (e) {
    // Bad instances will throw an exception, so no icon
    return null;
  }
}

Future<bool> isLemmyInstance(String? url) async {
  if (url?.isEmpty ?? true) {
    return false;
  }

  try {
    await LemmyApiV3(url!).run(const GetSite());
    return true;
  } catch (e) {
    return false;
  }
}
