import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/packages/ui/ui.dart';

import '../../helpers/ui_test_harness.dart';

void main() {
  testWidgets('ThunderSwipeActionBackground shows icon at given width', (tester) async {
    await pumpUiWidget(
      tester,
      const SizedBox(
        height: 80,
        width: 200,
        child: ThunderSwipeActionBackground(
          alignment: Alignment.centerRight,
          backgroundColor: Colors.red,
          width: 100,
          icon: Icons.delete,
        ),
      ),
    );

    expect(find.byIcon(Icons.delete), findsOneWidget);
    expect(find.byType(AnimatedContainer), findsOneWidget);
  });

  testWidgets('ThunderSwipeActionBackground hides icon when null', (tester) async {
    await pumpUiWidget(
      tester,
      const SizedBox(
        height: 80,
        width: 200,
        child: ThunderSwipeActionBackground(
          alignment: Alignment.centerLeft,
          backgroundColor: Colors.blue,
          width: 50,
        ),
      ),
    );

    expect(find.byType(Icon), findsNothing);
  });
}
