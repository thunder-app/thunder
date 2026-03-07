import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thunder/packages/ui/ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThunderImageViewer', () {
    testWidgets('invokes onTap after a single tap', (tester) async {
      var tapCount = 0;

      await _pumpViewer(
        tester,
        onTap: () => tapCount += 1,
      );

      await tester.tap(find.byType(ThunderImageViewer));
      await tester.pump(const Duration(milliseconds: 300));

      expect(tapCount, 1);
      expect(_currentScale(tester), closeTo(1.0, 0.01));
    });

    testWidgets('double tap zooms and suppresses single tap callback', (
      tester,
    ) async {
      var tapCount = 0;

      await _pumpViewer(
        tester,
        onTap: () => tapCount += 1,
      );

      await _doubleTapViewer(tester);

      expect(tapCount, 0);
      expect(_currentScale(tester), closeTo(2.0, 0.01));

      await tester.pump(const Duration(milliseconds: 300));
      expect(tapCount, 0);
    });

    testWidgets('double tap drag zoom adjusts the viewer scale', (
      tester,
    ) async {
      await _pumpViewer(tester);

      final center = tester.getCenter(find.byType(ThunderImageViewer));

      await _tapAt(tester, center);
      await tester.pump(const Duration(milliseconds: 60));

      final gesture = await tester.startGesture(center);
      await tester.pump();
      await gesture.moveBy(const Offset(0, -80));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(_currentScale(tester), greaterThan(1.45));
    });

    testWidgets('invokes onLongPress for a completed long press', (tester) async {
      var longPressCount = 0;

      await _pumpViewer(
        tester,
        onLongPress: () => longPressCount += 1,
      );

      await tester.longPress(find.byType(ThunderImageViewer));
      await tester.pumpAndSettle();

      expect(longPressCount, 1);
    });

    testWidgets('reports scale changes during double tap zoom', (tester) async {
      final reportedScales = <double>[];

      await _pumpViewer(
        tester,
        onScaleChanged: reportedScales.add,
      );

      await _doubleTapViewer(tester);

      expect(reportedScales, isNotEmpty);
      expect(reportedScales.last, closeTo(2.0, 0.01));
    });

    testWidgets('dragging vertically dismisses the viewer at base scale', (
      tester,
    ) async {
      var dismissCount = 0;

      await _pumpViewer(
        tester,
        onDismiss: () => dismissCount += 1,
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ThunderImageViewer)),
      );
      await tester.pump();
      await gesture.moveBy(const Offset(0, 140));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(dismissCount, 1);
    });

    testWidgets('drag to dismiss is ignored while zoomed in', (tester) async {
      var dismissCount = 0;

      await _pumpViewer(
        tester,
        onDismiss: () => dismissCount += 1,
      );

      await _doubleTapViewer(tester);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ThunderImageViewer)),
      );
      await tester.pump();
      await gesture.moveBy(const Offset(0, 160));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(dismissCount, 0);
      expect(_currentScale(tester), greaterThan(1.5));
    });
  });
}

Future<void> _doubleTapViewer(WidgetTester tester) async {
  final center = tester.getCenter(find.byType(ThunderImageViewer));

  await _tapAt(tester, center);
  await tester.pump(const Duration(milliseconds: 60));
  await _tapAt(tester, center);
  await tester.pumpAndSettle();
}

Future<void> _tapAt(WidgetTester tester, Offset position) async {
  final gesture = await tester.startGesture(position);
  await tester.pump();
  await gesture.up();
  await tester.pump();
}

double _currentScale(WidgetTester tester) {
  final transforms = tester
      .widgetList<Transform>(
        find.descendant(
          of: find.byType(ThunderImageViewer),
          matching: find.byType(Transform),
        ),
      )
      .toList();

  return transforms.map((transform) => transform.transform.getMaxScaleOnAxis()).reduce((value, element) => value > element ? value : element);
}

Future<void> _pumpViewer(
  WidgetTester tester, {
  VoidCallback? onDismiss,
  VoidCallback? onLongPress,
  ValueChanged<double>? onScaleChanged,
  VoidCallback? onTap,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            height: 300,
            width: 300,
            child: ThunderImageViewer(
              contentSize: const Size(100, 100),
              onDismiss: onDismiss,
              onLongPress: onLongPress,
              onScaleChanged: onScaleChanged,
              onTap: onTap,
              source: ThunderImageViewerSource.memory(_kTestImageBytes),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

final _kTestImageBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jx9kAAAAASUVORK5CYII=',
);
