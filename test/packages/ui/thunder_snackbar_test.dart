import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/packages/ui/ui.dart';

import '../../helpers/ui_test_harness.dart';

void main() {
  testWidgets('ThunderSnackbar keeps dismissible key across rebuilds', (tester) async {
    await pumpUiWidget(
      tester,
      StatefulBuilder(
        builder: (context, setState) => ThunderSnackbar(
          content: TextButton(
            onPressed: () => setState(() {}),
            child: const Text('snack content'),
          ),
        ),
      ),
    );

    final dismissibleFinder = find.byType(Dismissible);
    expect(dismissibleFinder, findsOneWidget);

    final keyBeforeRebuild = tester.widget<Dismissible>(dismissibleFinder).key;

    await tester.tap(find.text('snack content'));
    await tester.pump();

    final keyAfterRebuild = tester.widget<Dismissible>(dismissibleFinder).key;
    expect(keyBeforeRebuild, keyAfterRebuild);
  });
}
