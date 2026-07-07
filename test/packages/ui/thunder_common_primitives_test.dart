import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/packages/ui/ui.dart';

import '../../helpers/ui_test_harness.dart';

void main() {
  testWidgets('ThunderEmptyText renders italic muted message with custom padding', (tester) async {
    await pumpUiWidget(
      tester,
      const ThunderEmptyText(
        message: 'Nothing here',
        padding: EdgeInsets.all(7),
      ),
    );

    final padding = tester.widget<Padding>(find.byType(Padding).last);
    final text = tester.widget<Text>(find.text('Nothing here'));

    expect(padding.padding, const EdgeInsets.all(7));
    expect(text.style?.fontStyle, FontStyle.italic);
  });

  testWidgets('ThunderSkeletonBar and ThunderSkeletonPlaceholder render configured bars', (tester) async {
    await pumpUiWidget(
      tester,
      const Column(
        children: [
          ThunderSkeletonBar(width: 42, height: 8, opacity: 0.4),
          ThunderSkeletonPlaceholder(
            bars: [
              ThunderSkeletonBarSpec(width: 10),
              ThunderSkeletonBarSpec(width: 20, height: 12),
            ],
          ),
        ],
      ),
    );

    expect(find.byType(ThunderSkeletonBar), findsNWidgets(3));
  });

  testWidgets('ThunderSkeletonPlaceholder.post renders three default bars', (tester) async {
    await pumpUiWidget(tester, const ThunderSkeletonPlaceholder.post());

    expect(find.byType(ThunderSkeletonBar), findsNWidgets(3));
  });

  testWidgets('ThunderStateActions renders primary, secondary, and loading states', (tester) async {
    var firstPressed = false;
    var secondPressed = false;

    await pumpUiWidget(
      tester,
      ThunderStateActions(
        actions: [
          ThunderStateAction(label: 'Retry', onPressed: () => firstPressed = true),
          ThunderStateAction(label: 'Details', onPressed: () => secondPressed = true),
          ThunderStateAction(label: 'Loading', onPressed: () {}, loading: true),
        ],
      ),
    );

    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byType(TextButton), findsNWidgets(2));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.tap(find.text('Details'));
    await tester.pump();

    expect(firstPressed, isTrue);
    expect(secondPressed, isTrue);
  });

  testWidgets('ThunderStateActions returns empty box for no actions', (tester) async {
    await pumpUiWidget(tester, const ThunderStateActions(actions: []));

    expect(find.byType(SizedBox), findsWidgets);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('ThunderStateIcon uses compact and custom color configuration', (tester) async {
    await pumpUiWidget(
      tester,
      const Row(
        children: [
          ThunderStateIcon(icon: Icons.error, color: Colors.green),
          ThunderStateIcon(icon: Icons.warning, compact: true),
        ],
      ),
    );

    final icons = tester.widgetList<Icon>(find.byType(Icon)).toList();
    expect(icons.first.color, Colors.green);
    expect(icons.first.size, 100);
    expect(icons.last.size, 40);
  });

  testWidgets('ThunderStateText supports title-only, message-only, and italic message', (tester) async {
    await pumpUiWidget(
      tester,
      const Column(
        children: [
          ThunderStateText(title: 'Title only'),
          ThunderStateText(message: 'Message only', italic: true),
        ],
      ),
    );

    expect(find.text('Title only'), findsOneWidget);
    final message = tester.widget<Text>(find.text('Message only'));
    expect(message.style?.fontStyle, FontStyle.italic);
  });
}
