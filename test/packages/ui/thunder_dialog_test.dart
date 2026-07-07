import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/packages/ui/ui.dart';

import '../../helpers/ui_test_harness.dart';

void main() {
  testWidgets('ThunderDialog renders title and content', (tester) async {
    await pumpUiWidget(
      tester,
      const ThunderDialog(
        title: 'Confirm',
        contentText: 'Are you sure?',
        primaryButtonText: 'OK',
        secondaryButtonText: 'Cancel',
      ),
    );

    expect(find.text('Confirm'), findsOneWidget);
    expect(find.text('Are you sure?'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('ThunderDialog primary button respects enable callback', (tester) async {
    await pumpUiWidget(
      tester,
      ThunderDialog(
        title: 'Edit',
        contentWidgetBuilder: (setEnabled) => TextButton(
          onPressed: () => setEnabled(false),
          child: const Text('Disable'),
        ),
        primaryButtonText: 'Save',
        onPrimaryButtonPressed: (_, __) {},
      ),
    );

    final enabledSave = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'));
    expect(enabledSave.onPressed, isNotNull);

    await tester.tap(find.text('Disable'));
    await tester.pump();

    final disabledSave = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'));
    expect(disabledSave.onPressed, isNull);
  });

  testWidgets('showThunderDialog opens dialog portal', (tester) async {
    await pumpUiWidget(tester, const SizedBox.shrink());

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [ThunderTheme()]),
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () => showThunderDialog(
                context: context,
                title: 'Portal',
                contentText: 'From portal',
                primaryButtonText: 'Done',
              ),
              child: const Text('Open'),
            );
          },
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Portal'), findsOneWidget);
    expect(find.text('From portal'), findsOneWidget);
  });
}
