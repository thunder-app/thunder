import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/packages/ui/ui.dart';

import '../../helpers/ui_test_harness.dart';

void main() {
  testWidgets('ThunderBottomSheetListPicker shows header and items', (tester) async {
    var selected = false;

    await pumpUiWidget(
      tester,
      ThunderBottomSheetListPicker<String>(
        title: 'Choose one',
        closeOnSelect: false,
        items: const [
          ThunderPickerOption(label: 'Alpha', payload: 'a'),
          ThunderPickerOption(label: 'Beta', payload: 'b'),
        ],
        onSelect: (_) async => selected = true,
      ),
    );

    expect(find.text('Choose one'), findsOneWidget);
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);

    await tester.tap(find.text('Alpha'));
    await tester.pump();

    expect(selected, isTrue);
  });

  testWidgets('ThunderBottomSheetListPicker renders with previouslySelected', (tester) async {
    await pumpUiWidget(
      tester,
      ThunderBottomSheetListPicker<String>(
        title: 'Choose one',
        closeOnSelect: false,
        previouslySelected: 'b',
        items: const [
          ThunderPickerOption(label: 'Alpha', payload: 'a'),
          ThunderPickerOption(label: 'Beta', payload: 'b'),
        ],
      ),
    );

    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('ThunderBottomSheetListPicker scrolls long item lists', (tester) async {
    ThunderPickerOption<int>? selected;

    await pumpUiWidget(
      tester,
      SizedBox(
        height: 240,
        child: ThunderBottomSheetListPicker<int>(
          title: 'Long list',
          closeOnSelect: false,
          items: [
            for (var i = 0; i < 40; i++) ThunderPickerOption(label: 'Item $i', payload: i),
          ],
          onSelect: (item) async => selected = item,
        ),
      ),
    );

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 39'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Item 39'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Item 39'));
    await tester.pump();

    expect(selected?.payload, 39);
  });

  testWidgets('ThunderBottomSheetListPicker updates heading and checkbox rows without closing', (tester) async {
    var checked = false;

    await pumpUiWidget(
      tester,
      ThunderBottomSheetListPicker<String>(
        title: 'Choose many',
        closeOnSelect: false,
        heading: const Text('Initial heading'),
        onUpdateHeading: () => const Text('Updated heading'),
        items: [
          ThunderPickerOption(
            label: 'Checkbox',
            payload: 'checkbox',
            isChecked: () => checked,
          ),
        ],
        onSelect: (_) async => checked = true,
      ),
    );

    expect(find.text('Initial heading'), findsOneWidget);
    expect(find.byIcon(Icons.check_box_outline_blank_rounded), findsOneWidget);

    await tester.tap(find.text('Checkbox'));
    await tester.pump();

    expect(checked, isTrue);
    expect(find.text('Updated heading'), findsOneWidget);
    expect(find.byIcon(Icons.check_box_rounded), findsOneWidget);
  });
}
