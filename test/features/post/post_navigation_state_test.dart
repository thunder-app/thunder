import 'package:flutter_test/flutter_test.dart';
import 'package:thunder/src/features/post/presentation/state/post_navigation_cubit/post_navigation_cubit.dart';

void main() {
  test(
      'PostNavigationState.copyWith preserves highlightedCommentId when omitted',
      () {
    const state = PostNavigationState(highlightedCommentId: 42);

    final updated = state.copyWith(navigateCommentIndex: 5);

    expect(updated.highlightedCommentId, 42);
    expect(updated.navigateCommentIndex, 5);
  });
}
