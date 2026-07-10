import 'package:app_links/app_links.dart';

abstract class DeepLinkService {
  Stream<Uri?> get uriLinkStream;
}

class AppLinksDeepLinkService implements DeepLinkService {
  AppLinksDeepLinkService({AppLinks? appLinks}) : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;

  @override
  Stream<Uri?> get uriLinkStream => _appLinks.uriLinkStream;
}
