import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/shell/update_prompts.dart';

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
}
