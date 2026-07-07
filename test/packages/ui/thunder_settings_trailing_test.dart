import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/packages/ui/ui.dart';

import '../../helpers/ui_test_harness.dart';

Size _widgetSize(WidgetTester tester, Finder finder) {
  return tester.getSize(finder);
}

void main() {
  testWidgets('settings trailing widgets use their expected slot widths', (tester) async {
    await pumpUiWidget(
      tester,
      Column(
        children: [
          ThunderSettingsTile(
            title: 'Navigate',
            trailing: const ThunderSettingsChevronTrailing(),
          ),
          ThunderListOption<String>(
            title: 'Pick',
            value: const ThunderListPickerItem(label: 'One', payload: 'one'),
            options: const [ThunderListPickerItem(label: 'One', payload: 'one')],
          ),
          ThunderToggleOption(
            title: 'Toggle',
            value: true,
            onChanged: (_) {},
          ),
          const ThunderExpandableOption(
            title: 'Expand',
            child: Text('Body'),
          ),
        ],
      ),
    );

    const thunderTheme = ThunderTheme();
    const chevronSlotWidth = 20.0;
    final slotWidth = thunderTheme.settingsTileTrailingSlotWidth;

    expect(_widgetSize(tester, find.byType(ThunderSettingsChevronTrailing).first), Size(chevronSlotWidth, thunderTheme.settingsTileTrailingSlotHeight));
    expect(_widgetSize(tester, find.byType(ThunderSettingsChevronTrailing).last), Size(chevronSlotWidth, thunderTheme.settingsTileTrailingSlotHeight));
    expect(_widgetSize(tester, find.byType(ThunderSettingsSwitchTrailing)), Size(slotWidth, thunderTheme.settingsTileTrailingSlotHeight));
    expect(_widgetSize(tester, find.byType(ThunderSettingsExpandTrailing)), Size(slotWidth, thunderTheme.settingsTileTrailingSlotHeight));
  });

  testWidgets('toggle and list options align leading icon gap through ThunderSettingsTile', (tester) async {
    await pumpUiWidget(
      tester,
      Column(
        children: [
          ThunderListOption<String>(
            title: 'List',
            leading: const Icon(Icons.language_rounded, key: Key('list-icon')),
            value: const ThunderListPickerItem(label: 'One', payload: 'one'),
            options: const [ThunderListPickerItem(label: 'One', payload: 'one')],
          ),
          ThunderToggleOption(
            title: 'Toggle',
            value: true,
            iconEnabled: Icons.toggle_on,
            iconDisabled: Icons.toggle_off,
            onChanged: (_) {},
          ),
        ],
      ),
    );

    const thunderTheme = ThunderTheme();
    final listIconBox = tester.getRect(find.byKey(const Key('list-icon')));
    final toggleIconBox = tester.getRect(find.byIcon(Icons.toggle_on));
    final listTitleBox = tester.getRect(find.text('List'));
    final toggleTitleBox = tester.getRect(find.text('Toggle'));

    expect(listTitleBox.left - listIconBox.right, thunderTheme.settingsTileLeadingGap);
    expect(toggleTitleBox.left - toggleIconBox.right, thunderTheme.settingsTileLeadingGap);
  });

  testWidgets('ThunderSettingsChevronTrailing applies disabled color', (tester) async {
    await pumpUiWidget(
      tester,
      const ThunderSettingsChevronTrailing(disabled: true),
    );

    final icon = tester.widget<Icon>(find.byIcon(Icons.chevron_right_rounded));
    final theme = Theme.of(tester.element(find.byType(ThunderSettingsChevronTrailing)));
    const thunderTheme = ThunderTheme();

    expect(
      icon.color,
      theme.colorScheme.onSurface.withValues(alpha: thunderTheme.settingsTileDisabledAlpha),
    );
  });
}
