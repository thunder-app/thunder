import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/packages/ui/ui.dart';

import '../../helpers/ui_test_harness.dart';

void main() {
  testWidgets('ThunderSnackbar keeps dismissible key across rebuilds', (tester) async {
    await pumpUiWidget(
      tester,
      StatefulBuilder(
        builder: (context, setState) => ThunderSnackbar(
          content: TextButton(onPressed: () => setState(() {}), child: const Text('snack content')),
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

  testWidgets('replaces the current snackbar and dismisses after its duration', (tester) async {
    await pumpUiWidget(tester, const SizedBox());
    await tester.pumpAndSettle();
    expect(thunderNavigatorKey.currentState?.overlay, isNotNull);

    showThunderSnackbar('First', duration: const Duration(seconds: 10));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('First'), findsOneWidget);

    showThunderSnackbar('Second', duration: const Duration(seconds: 2));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Second'), findsNothing);
  });

  testWidgets('snackbar action dismisses the overlay and runs its callback', (tester) async {
    var actionCount = 0;
    await pumpUiWidget(tester, const SizedBox());
    await tester.pumpAndSettle();

    showThunderSnackbar('Retry', duration: Duration.zero, trailingIcon: Icons.refresh, trailingAction: () => actionCount++);
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();

    expect(actionCount, 1);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('snackbar can be dismissed by swiping', (tester) async {
    await pumpUiWidget(tester, const SizedBox());
    await tester.pumpAndSettle();

    showThunderSnackbar('Swipe me', duration: Duration.zero);
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.drag(find.text('Swipe me'), const Offset(0, 600));
    await tester.pumpAndSettle();
    expect(find.text('Swipe me'), findsNothing);
  });

  testWidgets('replaces a snackbar before it mounts and supports close', (tester) async {
    await pumpUiWidget(tester, const SizedBox());
    await tester.pumpAndSettle();

    showThunderSnackbar('First', duration: Duration.zero);
    showThunderSnackbar('Second', duration: Duration.zero);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsOneWidget);

    await tester.pump(const Duration(seconds: 20));
    expect(find.text('Second'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Second'), findsNothing);
  });

  testWidgets('can show a snackbar after the navigator is replaced', (tester) async {
    await pumpUiWidget(tester, const SizedBox());
    showThunderSnackbar('Old', duration: Duration.zero);
    await tester.pump();
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox());
    await pumpUiWidget(tester, const SizedBox());
    showThunderSnackbar('New', duration: Duration.zero);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('New'), findsOneWidget);
  });

  testWidgets('default duration scales with word count', (tester) async {
    await pumpUiWidget(tester, const SizedBox());
    showThunderSnackbar('one two three four five');
    await tester.pump();
    await tester.pumpAndSettle();

    await tester.pump(const Duration(milliseconds: 4900));
    expect(find.text('one two three four five'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    expect(find.text('one two three four five'), findsNothing);
  });

  testWidgets('overlay can be dismissed before or during its entrance', (tester) async {
    await pumpUiWidget(tester, const SizedBox());
    final overlay = thunderNavigatorKey.currentState!.overlay!;
    final beforeMount = showThunderOverlay(
      overlay: overlay,
      duration: Duration.zero,
      animationDuration: const Duration(milliseconds: 500),
      builder: (context, animation, dismiss) => const Text('Before mount'),
    );
    beforeMount.dismiss();
    beforeMount.dismiss();
    await tester.pump();
    expect(find.text('Before mount'), findsNothing);

    final duringEntrance = showThunderOverlay(
      overlay: overlay,
      duration: Duration.zero,
      animationDuration: const Duration(milliseconds: 500),
      builder: (context, animation, dismiss) => const Text('During entrance'),
    );
    await tester.pump();
    duringEntrance.dismiss();
    await tester.pumpAndSettle();
    expect(find.text('During entrance'), findsNothing);
  });
}
