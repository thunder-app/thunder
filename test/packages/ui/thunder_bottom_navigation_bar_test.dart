import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/packages/ui/ui.dart';

import '../../helpers/ui_test_harness.dart';

void main() {
  testWidgets('ThunderBottomNavigationBar selects destination on tap', (tester) async {
    var selectedIndex = 0;

    await pumpUiWidget(
      tester,
      ThunderBottomNavigationBar(
        selectedIndex: selectedIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
        ],
        onDestinationSelected: (index) => selectedIndex = index,
      ),
    );

    await tester.tap(find.text('Search'));
    await tester.pump();

    expect(selectedIndex, 1);
  });

  testWidgets('ThunderBottomNavigationBar fires long press callback', (tester) async {
    var longPressed = false;

    await pumpUiWidget(
      tester,
      ThunderBottomNavigationBar(
        selectedIndex: 0,
        longPressTimeout: const Duration(milliseconds: 50),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
        ],
        onDestinationSelected: (_) {},
        onDestinationLongPresses: {
          1: () => longPressed = true,
        },
      ),
    );

    final searchCenter = tester.getCenter(find.text('Search'));
    final gesture = await tester.startGesture(searchCenter);
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.up();
    await tester.pump();

    expect(longPressed, isTrue);
  });
}
