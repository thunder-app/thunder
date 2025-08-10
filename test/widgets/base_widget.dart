import 'package:flutter/material.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';

import 'package:thunder/src/app/utils/global_context.dart';

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
