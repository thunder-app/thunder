import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/packages/ui/ui.dart';

import '../../helpers/ui_test_harness.dart';

void main() {
  testWidgets('ThunderComposerBar renders slot children', (tester) async {
    await pumpUiWidget(
      tester,
      ThunderComposerBar(
        leading: const Icon(Icons.add),
        textField: const TextField(decoration: InputDecoration(hintText: 'Message')),
        trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.send)),
      ),
    );

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.send), findsOneWidget);
    expect(find.text('Message'), findsOneWidget);
  });
}
