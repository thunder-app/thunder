import 'package:lemmy_api_client/v3.dart';

class LemmyClient {
  LemmyApiV3 lemmyApiV3 = const LemmyApiV3('');

  LemmyClient._initialize();

  void changeBaseUrl(String baseUrl) {
    lemmyApiV3 = LemmyApiV3(baseUrl);
  }

  static final LemmyClient _instance = LemmyClient._initialize();

  static LemmyClient get instance => _instance;
}
