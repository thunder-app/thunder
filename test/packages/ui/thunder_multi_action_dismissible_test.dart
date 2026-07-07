import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/packages/ui/ui.dart';

import '../../helpers/ui_test_harness.dart';

void main() {
  testWidgets('ThunderMultiActionDismissible keeps dismissible key across rebuilds', (tester) async {
    await pumpUiWidget(
      tester,
      StatefulBuilder(
        builder: (context, setState) => ThunderMultiActionDismissible<void>(
          direction: DismissDirection.startToEnd,
          leftActions: [
            ThunderSwipeAction(
              value: null,
              color: (context) => Colors.red,
            ),
          ],
          rightActions: const [],
          child: TextButton(
            onPressed: () => setState(() {}),
            child: const Text('child'),
          ),
        ),
      ),
    );

    final dismissibleFinder = find.byType(Dismissible);
    expect(dismissibleFinder, findsOneWidget);

    final keyBeforeRebuild = tester.widget<Dismissible>(dismissibleFinder).key;

    await tester.tap(find.text('child'));
    await tester.pump();

    final keyAfterRebuild = tester.widget<Dismissible>(dismissibleFinder).key;
    expect(keyBeforeRebuild, keyAfterRebuild);
  });
}
