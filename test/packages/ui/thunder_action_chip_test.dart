import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/packages/ui/ui.dart';

import '../../helpers/ui_test_harness.dart';

void main() {
  testWidgets('ThunderActionChip labelWidget overrides default label', (tester) async {
    await pumpUiWidget(
      tester,
      const ThunderActionChip(
        label: 'Ignored',
        labelWidget: Text('Custom chip'),
      ),
    );

    expect(find.text('Custom chip'), findsOneWidget);
    expect(find.text('Ignored'), findsNothing);
  });
}
