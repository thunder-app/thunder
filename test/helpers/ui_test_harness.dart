import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n_esperanto/l10n_esperanto.dart';

import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/core/shell/legacy_ui_compatibility.dart';

Future<void> pumpUiWidget(WidgetTester tester, Widget child) async {
  GlobalContext.scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  await tester.pumpWidget(
    MaterialApp(
      scaffoldMessengerKey: GlobalContext.scaffoldMessengerKey,
      navigatorKey: thunderNavigatorKey,
      localizationsDelegates: const [AppLocalizations.delegate, MaterialLocalizationsEo.delegate, CupertinoLocalizationsEo.delegate, ...GlobalMaterialLocalizations.delegates],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(extensions: const [ThunderTheme()]),
      builder: (context, child) => LegacyUiCompatibility(child: child!),
      home: Scaffold(body: child),
    ),
  );
  await tester.pump();
}
