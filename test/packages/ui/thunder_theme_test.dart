import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/packages/ui/ui.dart';

void main() {
  test('ThunderTheme copyWith updates tokens', () {
    const theme = ThunderTheme();
    final updated = theme.copyWith(
      pickerSelectedAlpha: 0.4,
      sectionDescriptionAlpha: 0.6,
      viewerBackgroundColor: Colors.grey,
    );

    expect(updated.pickerSelectedAlpha, 0.4);
    expect(updated.sectionDescriptionAlpha, 0.6);
    expect(updated.viewerBackgroundColor, Colors.grey);
    expect(updated.tileBorderRadius, theme.tileBorderRadius);
  });

  test('ThunderTheme lerp interpolates numeric and color tokens', () {
    const start = ThunderTheme(
      pickerSelectedAlpha: 0.0,
      viewerBackgroundColor: Colors.black,
    );
    const end = ThunderTheme(
      pickerSelectedAlpha: 1.0,
      viewerBackgroundColor: Colors.white,
    );

    final mid = start.lerp(end, 0.5);

    expect(mid.pickerSelectedAlpha, closeTo(0.5, 0.001));
    expect(mid.viewerBackgroundColor, isNot(equals(start.viewerBackgroundColor)));
    expect(mid.viewerBackgroundColor, isNot(equals(end.viewerBackgroundColor)));
  });
}
