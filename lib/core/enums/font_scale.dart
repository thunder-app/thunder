import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/utils/global_context.dart';

enum FontScale {
  small,
  base,
  medium,
  large,
  extraLarge,
}

extension FontScaleExtension on FontScale {
  double get textScaleFactor {
    switch (this) {
      case FontScale.small:
        if (!kIsWeb && Platform.isIOS) return 0.9;
        return 0.9;
      case FontScale.base:
        if (!kIsWeb && Platform.isIOS) return 1;
        return 0.95;
      case FontScale.medium:
        if (!kIsWeb && Platform.isIOS) return 1.1;
        return 1.05;
      case FontScale.large:
        if (!kIsWeb && Platform.isIOS) return 1.15;
        return 1.2;
      case FontScale.extraLarge:
        if (!kIsWeb && Platform.isIOS) return 1.35;
        return 1.4;
    }
  }

  String get label {
    final l10n = AppLocalizations.of(GlobalContext.context)!;

    switch (this) {
      case FontScale.small:
        return l10n.small;
      case FontScale.base:
        return l10n.base;
      case FontScale.medium:
        return l10n.medium;
      case FontScale.large:
        return l10n.large;
      case FontScale.extraLarge:
        return l10n.extraLarge;
    }
  }
}
