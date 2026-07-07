import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/packages/ui/ui.dart';

import '../../helpers/ui_test_harness.dart';

void main() {
  testWidgets('ThunderSplitActionRow renders leading and trailing', (tester) async {
    await pumpUiWidget(
      tester,
      const ThunderSplitActionRow(
        leading: Text('Leading'),
        trailing: Text('Trailing'),
      ),
    );

    expect(find.text('Leading'), findsOneWidget);
    expect(find.text('Trailing'), findsOneWidget);
    expect(find.byType(ThunderSplitActionRow), findsOneWidget);
  });
}
