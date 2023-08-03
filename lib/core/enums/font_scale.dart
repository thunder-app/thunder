import 'dart:io';

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
        if (Platform.isIOS) return 0.85;
        return 0.9;
      case FontScale.base:
        if (Platform.isIOS) return 0.9;
        return 1.0;
      case FontScale.large:
        if (Platform.isIOS) return 1.15;
        return 1.2;
      case FontScale.extraLarge:
        if (Platform.isIOS) return 1.35;
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
