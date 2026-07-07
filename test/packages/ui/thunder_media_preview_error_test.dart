import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/packages/ui/ui.dart';

import '../../helpers/ui_test_harness.dart';

void main() {
  testWidgets('ThunderMediaPreviewError shows icon', (tester) async {
    await pumpUiWidget(
      tester,
      const SizedBox(
        height: 80,
        width: 80,
        child: ThunderMediaPreviewError(icon: Icons.image_not_supported_outlined),
      ),
    );

    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
  });

  testWidgets('ThunderMediaPreviewError shows retry when enabled', (tester) async {
    var retried = false;

    await pumpUiWidget(
      tester,
      SizedBox(
        height: 80,
        width: 80,
        child: ThunderMediaPreviewError(
          icon: Icons.image_not_supported_outlined,
          canRetry: true,
          onRetry: () => retried = true,
        ),
      ),
    );

    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await tester.pump();

    expect(retried, isTrue);
  });
}
