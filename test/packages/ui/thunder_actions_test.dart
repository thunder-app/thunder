import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/packages/ui/ui.dart';

import '../../helpers/ui_test_harness.dart';

void main() {
  testWidgets('ThunderBottomSheetAction renders slots and handles tap and long press', (tester) async {
    var tapped = false;
    var longPressed = false;

    await pumpUiWidget(
      tester,
      ThunderBottomSheetAction(
        leading: const Icon(Icons.info),
        trailing: const Icon(Icons.chevron_right),
        title: 'Details',
        subtitle: 'More information',
        onTap: () => tapped = true,
        onLongPress: () => longPressed = true,
      ),
    );

    expect(find.text('Details'), findsOneWidget);
    expect(find.text('More information'), findsOneWidget);
    expect(find.byIcon(Icons.info), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);

    await tester.tap(find.text('Details'));
    await tester.pump();
    await tester.longPress(find.text('Details'));
    await tester.pump();

    expect(tapped, isTrue);
    expect(longPressed, isTrue);
  });

  testWidgets('ThunderPopupMenuItem returns a value item with leading and trailing widgets', (tester) async {
    var tapped = false;
    final item = ThunderPopupMenuItem<String>(
      value: 'copy',
      onTap: () => tapped = true,
      icon: Icons.copy,
      title: 'Copy',
      trailing: const Icon(Icons.check),
    );

    expect(item.value, 'copy');

    await pumpUiWidget(tester, item.child!);

    expect(find.text('Copy'), findsOneWidget);
    expect(find.byIcon(Icons.copy), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);

    item.onTap?.call();
    expect(tapped, isTrue);
  });

  testWidgets('ThunderPreviewActionRow toggles source label and copy action stays tappable', (tester) async {
    var toggled = false;

    await pumpUiWidget(
      tester,
      ThunderPreviewActionRow(
        text: 'raw text',
        viewSource: false,
        onViewSourceToggled: () => toggled = true,
        viewSourceLabel: 'View source',
        viewOriginalLabel: 'View rendered',
        copyLabel: 'Copy',
        copiedMessage: 'Copied',
      ),
    );

    expect(find.text('View source'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);

    await tester.tap(find.text('View source'));
    await tester.pump();

    expect(toggled, isTrue);

    await tester.tap(find.text('Copy'));
    await tester.pump();
  });

  testWidgets('ThunderActionChip renders default icon label and ignores taps when disabled', (tester) async {
    var pressed = false;

    await pumpUiWidget(
      tester,
      Row(
        children: [
          ThunderActionChip(
            label: 'Enabled',
            icon: Icons.add,
            trailingIcon: Icons.check,
            onPressed: () => pressed = true,
          ),
          const ThunderActionChip(label: 'Disabled'),
        ],
      ),
    );

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);

    await tester.tap(find.text('Enabled'));
    await tester.pump();
    await tester.tap(find.text('Disabled'));
    await tester.pump();

    expect(pressed, isTrue);
  });
}
