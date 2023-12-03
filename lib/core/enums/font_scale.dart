import 'dart:io';

import 'package:flutter/foundation.dart';

enum FontScale {
  small,
  base,
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
      case FontScale.large:
        if (!kIsWeb && Platform.isIOS) return 1.15;
        return 1.2;
      case FontScale.extraLarge:
        if (!kIsWeb && Platform.isIOS) return 1.35;
        return 1.4;
    }
  }

  String get label {
    switch (this) {
      case FontScale.small:
        return 'Small';
      case FontScale.base:
        return 'Base';
      case FontScale.large:
        return 'Large';
      case FontScale.extraLarge:
        return 'Extra Large';
    }
  }
}
