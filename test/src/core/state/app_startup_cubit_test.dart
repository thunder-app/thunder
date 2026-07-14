import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/core/state/app_startup_cubit.dart';

void main() {
  blocTest<AppStartupCubit, AppStartupState>(
    'emits running then ready when maintenance succeeds',
    build: () => AppStartupCubit(taskRunner: () async {}),
    act: (cubit) => cubit.initialize(),
    expect: () => const [
      AppStartupState(status: AppStartupStatus.running),
      AppStartupState(status: AppStartupStatus.ready),
    ],
  );

  blocTest<AppStartupCubit, AppStartupState>(
    'emits failure and retries maintenance',
    build: () {
      var attempts = 0;
      return AppStartupCubit(
        taskRunner: () async {
          attempts++;
          if (attempts == 1) throw StateError('maintenance failed');
        },
      );
    },
    act: (cubit) async {
      await cubit.initialize();
      await cubit.initialize();
    },
    expect: () => [
      const AppStartupState(status: AppStartupStatus.running),
      isA<AppStartupState>().having((state) => state.status, 'status', AppStartupStatus.failure),
      const AppStartupState(status: AppStartupStatus.running),
      const AppStartupState(status: AppStartupStatus.ready),
    ],
  );

  test('does not start maintenance twice while running', () async {
    final completer = Completer<void>();
    var attempts = 0;
    final cubit = AppStartupCubit(
      taskRunner: () {
        attempts++;
        return completer.future;
      },
    );

    final first = cubit.initialize();
    await cubit.initialize();

    expect(attempts, 1);
    completer.complete();
    await first;
    await cubit.close();
  });
}
