import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/utils/global_context.dart';

/// Base widget for simple tests which requires localization
class BaseWidget extends StatelessWidget {
  const BaseWidget({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      scaffoldMessengerKey: GlobalContext.scaffoldMessengerKey,
      home: child,
    );
  }
}
