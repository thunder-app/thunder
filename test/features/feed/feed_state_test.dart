import 'package:flutter_test/flutter_test.dart';
import 'package:thunder/src/features/feed/presentation/state/feed_bloc.dart';

void main() {
  test('FeedState.copyWith preserves excessiveApiCalls by default', () {
    const state = FeedState(excessiveApiCalls: true);

    final updated = state.copyWith(status: FeedStatus.success);

    expect(updated.excessiveApiCalls, isTrue);
  });
}
