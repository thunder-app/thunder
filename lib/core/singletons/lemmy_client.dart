import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:lemmy/lemmy.dart';

class LemmyClient {
  Lemmy lemmy = Lemmy(baseUrl: dotenv.env['LEMMY_BASE_URL']!);

  LemmyClient._initialize();

  void changeBaseUrl(String baseUrl) {
    lemmy = Lemmy(baseUrl: baseUrl);
  }

  static final LemmyClient _instance = LemmyClient._initialize();

  static LemmyClient get instance => _instance;
}
