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
        return 0.9;
      case FontScale.base:
        return 1.0;
      case FontScale.large:
        return 1.2;
      case FontScale.extraLarge:
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
