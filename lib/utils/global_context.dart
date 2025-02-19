import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GlobalContext {
  static GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  static BuildContext get context => scaffoldMessengerKey.currentContext!;
  static AppLocalizations get l10n => AppLocalizations.of(context)!;
}
