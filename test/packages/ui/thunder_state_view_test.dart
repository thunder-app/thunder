import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/packages/ui/ui.dart';

import '../../helpers/ui_test_harness.dart';

void main() {
  testWidgets('ThunderStateView shows error title and retry action', (tester) async {
    var retried = false;

    await pumpUiWidget(
      tester,
      ThunderStateView(
        title: 'Load failed',
        message: 'Try again',
        actions: [
          ThunderStateAction(
            label: 'Retry',
            onPressed: () => retried = true,
            primary: true,
          ),
        ],
      ),
    );

    expect(find.text('Load failed'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.byIcon(Icons.warning_rounded), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(retried, isTrue);
  });

  testWidgets('ThunderStateView.loading shows progress indicator', (tester) async {
    await pumpUiWidget(tester, const ThunderStateView.loading());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('ThunderStateView empty mode renders italic text', (tester) async {
    await pumpUiWidget(
      tester,
      const ThunderStateView(
        mode: ThunderStateViewMode.empty,
        title: 'Nothing here',
      ),
    );

    expect(find.text('Nothing here'), findsOneWidget);
  });

  testWidgets('ThunderStateView custom mode renders child', (tester) async {
    await pumpUiWidget(
      tester,
      const ThunderStateView(
        mode: ThunderStateViewMode.custom,
        child: Text('Custom body'),
      ),
    );

    expect(find.text('Custom body'), findsOneWidget);
  });

  testWidgets('ThunderStateView sliver mode renders inside CustomScrollView', (tester) async {
    await pumpUiWidget(
      tester,
      CustomScrollView(
        slivers: [
          const ThunderStateView.loading(sliver: true),
        ],
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(SliverFillRemaining), findsOneWidget);
  });
}
