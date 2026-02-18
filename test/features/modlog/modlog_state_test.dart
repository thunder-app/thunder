import 'package:flutter_test/flutter_test.dart';
import 'package:thunder/src/foundation/errors/app_error_reason.dart';
import 'package:thunder/src/features/modlog/modlog.dart';

void main() {
  group('ModlogState.errorReason', () {
    test('returns null when message is null', () {
      const state = ModlogState();
      expect(state.errorReason, isNull);
    });

    test('returns typed unexpected reason when message exists', () {
      const state = ModlogState(
        status: ModlogStatus.failure,
        message: 'failed to fetch modlog',
      );

      expect(state.errorReason?.category, AppErrorCategory.unexpected);
      expect(state.errorReason?.message, 'failed to fetch modlog');
    });
  });
}
