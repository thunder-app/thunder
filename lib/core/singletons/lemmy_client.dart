import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:lemmy_api_client/v3.dart';

class LemmyClient {
  LemmyApiV3 lemmyApiV3 =
      LemmyApiV3(dotenv.env['LEMMY_BASE_URL'] ?? 'lemmy.ml');

  LemmyClient._initialize();

  void changeBaseUrl(String baseUrl) {
    lemmyApiV3 = LemmyApiV3(baseUrl);
  }

  static final LemmyClient _instance = LemmyClient._initialize();

  static LemmyClient get instance => _instance;
}
