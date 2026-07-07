import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/packages/ui/ui.dart';

import '../../helpers/ui_test_harness.dart';

final Uint8List _onePixelPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
);

void main() {
  test('ThunderImageViewerSource factories preserve source data and content type', () {
    final memory = ThunderImageViewerSource.memory(_onePixelPng, contentType: 'image/png');
    const network = ThunderImageViewerSource.network('https://example.com/image.png', contentType: 'image/png');

    expect(memory, isA<ThunderImageViewerMemorySource>());
    expect((memory as ThunderImageViewerMemorySource).bytes, _onePixelPng);
    expect(memory.contentType, 'image/png');
    expect(network, isA<ThunderImageViewerNetworkSource>());
    expect((network as ThunderImageViewerNetworkSource).url, 'https://example.com/image.png');
  });

  testWidgets('ThunderImageViewer renders memory source and handles tap, long press, and double tap scale', (tester) async {
    var tapped = false;
    var longPressed = false;
    final scales = <double>[];

    await pumpUiWidget(
      tester,
      SizedBox(
        height: 300,
        width: 300,
        child: ThunderImageViewer(
          source: ThunderImageViewerSource.memory(_onePixelPng),
          semanticLabel: 'Memory image',
          onTap: () => tapped = true,
          onLongPress: () => longPressed = true,
          onScaleChanged: scales.add,
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);

    await tester.tap(find.byType(ThunderImageViewer));
    await tester.pump(const Duration(milliseconds: 40));
    await tester.tap(find.byType(ThunderImageViewer));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ThunderImageViewer));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.longPress(find.byType(ThunderImageViewer));
    await tester.pump();

    expect(tapped, isTrue);
    expect(longPressed, isTrue);
    expect(scales, isNotEmpty);
  });

  testWidgets('ThunderImageViewer renders custom network loading builder', (tester) async {
    await pumpUiWidget(
      tester,
      SizedBox(
        height: 200,
        width: 200,
        child: ThunderImageViewer(
          source: const ThunderImageViewerSource.network('https://example.invalid/image.png'),
          loadingBuilder: (_) => const Text('Loading image'),
        ),
      ),
    );

    expect(find.text('Loading image'), findsOneWidget);
  });

  testWidgets('ThunderMediaPreviewError hides on blur and retries when enabled', (tester) async {
    var retried = false;

    await pumpUiWidget(
      tester,
      Column(
        children: [
          const ThunderMediaPreviewError(icon: Icons.broken_image, blur: true),
          ThunderMediaPreviewError(
            icon: Icons.broken_image,
            viewed: true,
            canRetry: true,
            retryTooltip: 'Try again',
            onRetry: () => retried = true,
          ),
        ],
      ),
    );

    expect(find.byIcon(Icons.broken_image), findsNothing);
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await tester.pump();

    expect(retried, isTrue);
  });
}
