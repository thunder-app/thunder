import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/packages/ui/ui.dart';

import '../../helpers/ui_test_harness.dart';

void main() {
  testWidgets('ThunderPickerItem supports slots, selection, disabled, and tap', (tester) async {
    var selected = false;

    await pumpUiWidget(
      tester,
      Column(
        children: [
          ThunderPickerItem(
            label: 'Alpha',
            subtitle: 'First',
            icon: Icons.filter_1,
            trailingIcon: Icons.check,
            isSelected: true,
            onSelected: () => selected = true,
          ),
          const ThunderPickerItem(
            label: 'Ignored',
            labelWidget: Text('Custom label'),
            subtitleWidget: Text('Custom subtitle'),
            leading: Icon(Icons.star),
          ),
        ],
      ),
    );

    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('First'), findsOneWidget);
    expect(find.byIcon(Icons.filter_1), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.text('Custom label'), findsOneWidget);
    expect(find.text('Custom subtitle'), findsOneWidget);

    await tester.tap(find.text('Alpha'));
    await tester.pump();
    expect(selected, isTrue);
  });

  testWidgets('ThunderMultiPickerItem renders enabled and disabled buttons with tooltips', (tester) async {
    var picked = false;

    await pumpUiWidget(
      tester,
      ThunderMultiPickerItem(
        pickerItems: [
          ThunderMultiPickerItemData(label: 'Pick', icon: Icons.add, onSelected: () => picked = true, foregroundColor: Colors.green),
          const ThunderMultiPickerItemData(label: 'Disabled', icon: Icons.remove, onSelected: null),
        ],
      ),
    );

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.remove), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(picked, isTrue);
  });

  testWidgets('showThunderListPicker opens default picker and custom picker override', (tester) async {
    await pumpUiWidget(
      tester,
      Builder(
        builder: (context) => Column(
          children: [
            TextButton(
              onPressed: () => showThunderListPicker<String>(
                context: context,
                title: 'Pick one',
                items: const [
                  ThunderListPickerItem(label: 'One', payload: 'one'),
                  ThunderListPickerItem(label: 'Two', payload: 'two'),
                ],
                selected: const ThunderListPickerItem(label: 'One', payload: 'one'),
              ),
              child: const Text('Open default'),
            ),
            TextButton(
              onPressed: () => showThunderListPicker<String>(
                context: context,
                title: 'Ignored',
                items: const [],
                selected: const ThunderListPickerItem(label: 'Empty', payload: 'empty'),
                customPicker: const Text('Custom picker'),
              ),
              child: const Text('Open custom'),
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Open default'));
    await tester.pumpAndSettle();
    expect(find.text('Pick one'), findsOneWidget);
    expect(find.text('Two'), findsOneWidget);

    await tester.tap(find.text('One'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open custom'));
    await tester.pumpAndSettle();
    expect(find.text('Custom picker'), findsOneWidget);
  });

  testWidgets('ThunderListOption displays formatted value and opens custom picker', (tester) async {
    await pumpUiWidget(
      tester,
      ThunderListOption<String>(
        title: 'Sort',
        subtitle: 'Choose sort',
        value: const ThunderListPickerItem(label: 'newComments', payload: 'new'),
        options: const [
          ThunderListPickerItem(label: 'hot', payload: 'hot'),
          ThunderListPickerItem(label: 'newComments', payload: 'new'),
        ],
        customListPicker: const Text('Custom list picker'),
      ),
    );

    expect(find.text('Sort'), findsOneWidget);
    expect(find.text('Choose sort'), findsOneWidget);
    expect(find.textContaining('Comments'), findsOneWidget);

    await tester.tap(find.text('Sort'));
    await tester.pumpAndSettle();
    expect(find.text('Custom list picker'), findsOneWidget);
  });

  testWidgets('ThunderListOption disabled does not open picker', (tester) async {
    await pumpUiWidget(
      tester,
      const ThunderListOption<String>(
        title: 'Disabled sort',
        disabled: true,
        value: ThunderListPickerItem(label: 'hot', payload: 'hot'),
        options: [ThunderListPickerItem(label: 'hot', payload: 'hot')],
      ),
    );

    await tester.tap(find.text('Disabled sort'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('ThunderToggleOption toggles via tile and switch and respects disabled state', (tester) async {
    final values = <bool>[];

    await pumpUiWidget(
      tester,
      Column(
        children: [
          ThunderToggleOption(
            title: 'Toggle',
            value: false,
            onChanged: values.add,
            iconEnabled: Icons.toggle_on,
            iconDisabled: Icons.toggle_off,
            additionalTrailing: const [Text('Extra')],
          ),
          ThunderToggleOption(
            title: 'Disabled toggle',
            value: true,
            disabled: true,
            onChanged: values.add,
          ),
          const ThunderToggleOption(title: 'Placeholder'),
        ],
      ),
    );

    await tester.tap(find.text('Toggle'));
    await tester.pump();
    await tester.tap(find.byType(Switch).first);
    await tester.pump();
    await tester.tap(find.text('Disabled toggle'));
    await tester.pump();

    expect(values, [true, true]);
    expect(find.text('Extra'), findsOneWidget);
    expect(find.byType(ThunderSettingsSwitchTrailing), findsWidgets);
  });

  testWidgets('ThunderExpandableOption toggles child visibility', (tester) async {
    await pumpUiWidget(
      tester,
      const ThunderExpandableOption(
        title: 'Advanced',
        leading: Icon(Icons.tune),
        child: Text('Advanced body'),
      ),
    );

    expect(find.text('Advanced body'), findsNothing);
    await tester.tap(find.text('Advanced'));
    await tester.pumpAndSettle();
    expect(find.text('Advanced body'), findsOneWidget);
    await tester.tap(find.text('Advanced'));
    await tester.pumpAndSettle();
    expect(find.text('Advanced body'), findsNothing);
  });
}
