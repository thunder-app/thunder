import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:lemmy/lemmy.dart';

class LemmyClient {
  LemmyClient._();

  final lemmy = Lemmy(
    baseUrl: dotenv.env['LEMMY_BASE_URL']!,
  );

  static final instance = LemmyClient._().lemmy;
}
