import 'package:bloc_test/bloc_test.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thunder/src/app/state/thunder/thunder_bloc.dart';
import 'package:thunder/src/foundation/primitives/enums/local_settings.dart';
import 'package:thunder/src/foundation/errors/app_error_reason.dart';
import 'package:thunder/src/foundation/primitives/models/version.dart';
import 'package:thunder/src/foundation/contracts/version_checker.dart';

import '../helpers/fake_preferences_store.dart';

class _FailingVersionChecker implements VersionChecker {
  const _FailingVersionChecker();

  @override
  Future<Version> fetchLatestVersion() async {
    throw Exception('network down');
  }
}

class _SuccessVersionChecker implements VersionChecker {
  const _SuccessVersionChecker();

  @override
  Future<Version> fetchLatestVersion() async {
    return Version(version: '0.0.1');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  EquatableConfig.stringify = false;

  group('ThunderBloc', () {
    blocTest<ThunderBloc, ThunderState>(
      'emits typed error reason when initialization fails',
      build: () => ThunderBloc(
        preferencesStore: FakePreferencesStore(),
        versionChecker: const _FailingVersionChecker(),
      ),
      act: (bloc) => bloc.add(InitializeAppEvent()),
      expect: () => [
        isA<ThunderState>()
            .having((state) => state.status, 'status', ThunderStatus.failure)
            .having((state) => state.errorReason?.category, 'category',
                AppErrorCategory.unexpected),
      ],
    );

    blocTest<ThunderBloc, ThunderState>(
      'clears error reason on successful preference load',
      build: () => ThunderBloc(
        preferencesStore: FakePreferencesStore(settings: {
          LocalSettings.currentAnonymousInstance: 'lemmy.world',
        }),
        versionChecker: const _SuccessVersionChecker(),
      ),
      seed: () => const ThunderState(
        status: ThunderStatus.failure,
        errorMessage: 'old',
        errorReason: AppErrorReason.unexpected(message: 'old'),
      ),
      act: (bloc) => bloc.add(UserPreferencesChangeEvent()),
      expect: () => [
        isA<ThunderState>().having(
            (state) => state.status, 'status', ThunderStatus.refreshing),
        isA<ThunderState>()
            .having((state) => state.status, 'status', ThunderStatus.success)
            .having((state) => state.errorReason, 'errorReason', isNull),
      ],
    );
  });
}
