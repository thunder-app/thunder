import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/foundation/config/global_context.dart';

Future<void> pumpUiWidget(WidgetTester tester, Widget child) async {
  GlobalContext.scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  await tester.pumpWidget(
    MaterialApp(
      scaffoldMessengerKey: GlobalContext.scaffoldMessengerKey,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(extensions: const [ThunderTheme()]),
      home: Scaffold(body: child),
    ),
  );
  await tester.pump();
}
