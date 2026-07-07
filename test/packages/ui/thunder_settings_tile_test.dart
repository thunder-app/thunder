import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/packages/ui/ui.dart';

import '../../helpers/ui_test_harness.dart';

void main() {
  testWidgets('ThunderSettingsTile titleWidget overrides default title', (tester) async {
    await pumpUiWidget(
      tester,
      const ThunderSettingsTile(
        title: 'Ignored',
        titleWidget: Text('Custom title'),
      ),
    );

    expect(find.text('Custom title'), findsOneWidget);
    expect(find.text('Ignored'), findsNothing);
  });
}
