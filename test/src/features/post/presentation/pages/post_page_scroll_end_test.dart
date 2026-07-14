import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/features/post/presentation/pages/post_page.dart';

void main() {
  testWidgets('persists once after a fling becomes idle', (tester) async {
    var persistenceCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PostScrollEndListener(
            onScrollEnd: () => persistenceCount += 1,
            child: ListView.builder(
              itemExtent: 100,
              itemCount: 50,
              itemBuilder: (context, index) => Text('Item $index'),
            ),
          ),
        ),
      ),
    );

    await tester.fling(find.byType(ListView), const Offset(0, -600), 2000);
    await tester.pumpAndSettle();

    expect(persistenceCount, 1);
  });

  testWidgets('persists after programmatic scrolling stops', (tester) async {
    final controller = ScrollController();
    var persistenceCount = 0;
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PostScrollEndListener(
            onScrollEnd: () => persistenceCount += 1,
            child: ListView.builder(
              controller: controller,
              itemExtent: 100,
              itemCount: 50,
              itemBuilder: (context, index) => Text('Item $index'),
            ),
          ),
        ),
      ),
    );

    controller.animateTo(500, duration: const Duration(milliseconds: 250), curve: Curves.linear);
    await tester.pumpAndSettle();

    expect(persistenceCount, 1);
  });
}
