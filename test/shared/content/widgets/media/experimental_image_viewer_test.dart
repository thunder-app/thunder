import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/shared/content/widgets/media/experimental_image_viewer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExperimentalImageViewer', () {
    testWidgets('single tap closes the viewer when chrome is visible', (tester) async {
      await _pumpRouteHost(tester);

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(ExperimentalImageViewer), findsOneWidget);

      await _tapAt(tester, tester.getCenter(find.byType(ThunderImageViewer)));
      await tester.pump(const Duration(milliseconds: 320));
      await tester.pumpAndSettle();

      expect(find.byType(ExperimentalImageViewer), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('long press enters fullscreen and tap exits fullscreen without popping', (tester) async {
      await _pumpRouteHost(tester);

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.longPress(find.byType(ThunderImageViewer));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.fullscreen_exit_rounded), findsOneWidget);

      await _tapAt(tester, tester.getCenter(find.byType(ThunderImageViewer)));
      await tester.pump(const Duration(milliseconds: 320));
      await tester.pumpAndSettle();

      expect(find.byType(ExperimentalImageViewer), findsOneWidget);
      expect(find.byIcon(Icons.fullscreen_exit_rounded), findsNothing);
    });

    testWidgets('zooming in automatically enters fullscreen chrome state', (tester) async {
      await _pumpRouteHost(tester);

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await _doubleTapAt(tester, tester.getCenter(find.byType(ThunderImageViewer)));

      expect(find.byIcon(Icons.fullscreen_exit_rounded), findsOneWidget);
    });
  });
}

Future<void> _pumpRouteHost(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(useMaterial3: false),
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ExperimentalImageViewer(bytes: _kTestImageBytes),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          );
        },
      ),
    ),
  );

  await tester.pumpAndSettle();
}

Future<void> _doubleTapAt(WidgetTester tester, Offset position) async {
  await _tapAt(tester, position);
  await tester.pump(const Duration(milliseconds: 60));
  await _tapAt(tester, position);
  await tester.pumpAndSettle();
}

Future<void> _tapAt(WidgetTester tester, Offset position) async {
  final gesture = await tester.startGesture(position);
  await tester.pump();
  await gesture.up();
  await tester.pump();
}

final _kTestImageBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jx9kAAAAASUVORK5CYII=',
);
