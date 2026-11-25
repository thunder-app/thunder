import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/shell/update_prompts.dart';

import '../../../helpers/ui_test_harness.dart';

void main() {
  final update = Version(version: '1.0.0', latestVersion: '2.0.0', hasUpdate: true);

  test('returns an update once when the version arrives before the profile', () {
    final coordinator = UpdateNotificationCoordinator();

    expect(coordinator.nextNotification(version: update, profileIsUsable: false, enabled: true), isNull);
    expect(coordinator.nextNotification(version: update, profileIsUsable: true, enabled: true), same(update));
    expect(coordinator.nextNotification(version: update, profileIsUsable: true, enabled: true), isNull);
  });

  test('returns an update once when the profile arrives before the version', () {
    final coordinator = UpdateNotificationCoordinator();

    expect(coordinator.nextNotification(version: null, profileIsUsable: true, enabled: true), isNull);
    expect(coordinator.nextNotification(version: update, profileIsUsable: true, enabled: true), same(update));
    expect(coordinator.nextNotification(version: update, profileIsUsable: true, enabled: true), isNull);
  });

  test('does not return disabled or unavailable updates', () {
    final coordinator = UpdateNotificationCoordinator();
    final current = Version(version: '1.0.0', latestVersion: '1.0.0');

    expect(coordinator.nextNotification(version: update, profileIsUsable: true, enabled: false), isNull);
    expect(coordinator.nextNotification(version: current, profileIsUsable: true, enabled: true), isNull);
  });

  testWidgets('shows an update at the top and dismisses it after five seconds', (tester) async {
    late BuildContext context;
    await pumpUiWidget(tester, Builder(builder: (value) {
      context = value;
      return const SizedBox();
    }));

    showUpdateNotification(context, update);
    await tester.pump();
    await tester.pumpAndSettle();
    final notification = find.text('Update released: 2.0.0');
    expect(notification, findsOneWidget);
    expect(tester.getTopLeft(notification).dy, lessThan(100));

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(notification, findsNothing);
  });

  testWidgets('update notification can be dismissed by swiping', (tester) async {
    late BuildContext context;
    await pumpUiWidget(tester, Builder(builder: (value) {
      context = value;
      return const SizedBox();
    }));

    showUpdateNotification(context, update);
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.drag(find.text('Update released: 2.0.0'), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Update released: 2.0.0'), findsNothing);
  });

  testWidgets('update notification and snackbar can coexist', (tester) async {
    late BuildContext context;
    await pumpUiWidget(tester, Builder(builder: (value) {
      context = value;
      return const SizedBox();
    }));

    showUpdateNotification(context, update);
    showThunderSnackbar('Snackbar', duration: Duration.zero);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Update released: 2.0.0'), findsOneWidget);
    expect(find.text('Snackbar'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Update released: 2.0.0'), findsNothing);
    expect(find.text('Snackbar'), findsOneWidget);
  });
}
