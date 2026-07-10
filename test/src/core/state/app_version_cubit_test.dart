import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/services/services.dart';
import 'package:thunder/src/core/state/app_version_cubit.dart';

class _VersionChecker implements VersionChecker {
  _VersionChecker(this.fetch);

  final Future<Version> Function() fetch;

  @override
  Future<Version> fetchLatestVersion() => fetch();
}

void main() {
  final version = Version(version: '1.0.0', latestVersion: '2.0.0', hasUpdate: true);

  blocTest<AppVersionCubit, AppVersionState>(
    'reports a successful optional version check',
    build: () => AppVersionCubit(versionChecker: _VersionChecker(() async => version)),
    act: (cubit) => cubit.checkForUpdate(),
    expect: () => [
      const AppVersionState(status: AppVersionStatus.checking),
      isA<AppVersionState>().having((state) => state.status, 'status', AppVersionStatus.success).having((state) => state.version, 'version', same(version)),
    ],
  );

  blocTest<AppVersionCubit, AppVersionState>(
    'contains failures without throwing',
    build: () => AppVersionCubit(versionChecker: _VersionChecker(() async => throw StateError('unavailable'))),
    act: (cubit) => cubit.checkForUpdate(),
    expect: () => [
      const AppVersionState(status: AppVersionStatus.checking),
      isA<AppVersionState>().having((state) => state.status, 'status', AppVersionStatus.failure).having((state) => state.errorMessage, 'errorMessage', contains('unavailable')),
    ],
  );

  test('a pending version check does not complete unrelated work', () async {
    final result = Completer<Version>();
    final cubit = AppVersionCubit(versionChecker: _VersionChecker(() => result.future));

    final check = cubit.checkForUpdate();
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.status, AppVersionStatus.checking);

    result.complete(version);
    await check;
    await cubit.close();
  });
}
