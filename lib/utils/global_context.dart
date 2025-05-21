import 'package:flutter/material.dart';

import 'package:thunder/localizations/app_localizations.dart';

class GlobalContext {
  static GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  static BuildContext get context => scaffoldMessengerKey.currentContext!;
  static AppLocalizations get l10n => AppLocalizations.of(context)!;
}
