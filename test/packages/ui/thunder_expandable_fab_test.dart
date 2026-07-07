import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/packages/ui/ui.dart';

import '../../helpers/ui_test_harness.dart';

void main() {
  testWidgets('ThunderExpandableFab controlled open syncs with parent', (tester) async {
    var isOpen = false;

    await pumpUiWidget(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          return SizedBox(
            height: 300,
            width: 300,
            child: Column(
              children: [
                Switch(
                  value: isOpen,
                  onChanged: (value) => setState(() => isOpen = value),
                ),
                Expanded(
                  child: ThunderExpandableFab(
                    open: isOpen,
                    distance: 60,
                    icon: const Icon(Icons.add),
                    children: const [
                      ThunderFabActionButton(icon: Icon(Icons.edit), label: 'Edit'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    expect(find.text('Edit'), findsNothing);

    await tester.tap(find.byType(Switch));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Edit'), findsOneWidget);
  });

  testWidgets('ThunderExpandableFab opens on vertical drag up', (tester) async {
    await pumpUiWidget(
      tester,
      const SizedBox(
        height: 300,
        width: 300,
        child: ThunderExpandableFab(
          distance: 60,
          icon: Icon(Icons.add),
          children: [
            ThunderFabActionButton(icon: Icon(Icons.edit), label: 'Edit'),
          ],
        ),
      ),
    );

    expect(find.text('Edit'), findsNothing);

    await tester.drag(find.byType(FloatingActionButton), const Offset(0, -80));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Edit'), findsOneWidget);
  });
}
