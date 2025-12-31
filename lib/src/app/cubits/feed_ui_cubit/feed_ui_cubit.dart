import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'feed_ui_state.dart';

/// Cubit for managing feed's state for certain actions
class FeedUiCubit extends Cubit<FeedUiState> {
  FeedUiCubit() : super(const FeedUiState());

  /// Increments the scrollId. This is used to trigger a scroll to top action
  void scrollToTop() {
    emit(state.copyWith(scrollId: state.scrollId + 1));
  }

  /// Increments the dismissReadId. This is used to trigger dismissing read posts action
  void dismissRead() {
    emit(state.copyWith(dismissReadId: state.dismissReadId + 1));
  }

  /// Sets the dismiss blocked user/community IDs. This is used to trigger dismissing blocked user/community posts action
  void dismissBlocked({int? userId, int? communityId}) {
    emit(state.copyWith(
      dismissBlockedUserId: userId,
      dismissBlockedCommunityId: communityId,
    ));
  }

  /// Sets the dismiss hidden post ID. This is used to trigger dismissing hidden posts action
  void dismissHiddenPost(int postId) {
    emit(state.copyWith(dismissHiddenPostId: postId));
  }

  /// Clears the dismiss hidden post ID
  void clearDismissHiddenPost() {
    emit(state.copyWith(dismissHiddenPostId: null));
  }

  /// Clears the dismiss blocked user/community IDs
  void clearDismissBlocked() {
    emit(state.copyWith(
      dismissBlockedUserId: null,
      dismissBlockedCommunityId: null,
    ));
  }
}
