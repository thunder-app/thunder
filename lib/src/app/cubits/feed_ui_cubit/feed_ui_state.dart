part of 'feed_ui_cubit.dart';

class FeedUiState extends Equatable {
  const FeedUiState({
    this.scrollId = 0,
    this.dismissReadId = 0,
    this.dismissBlockedUserId,
    this.dismissBlockedCommunityId,
    this.dismissHiddenPostId,
  });

  /// This id is used for scrolling back to the top
  final int scrollId;

  /// This id is used for dismissing already read posts in the feed
  final int dismissReadId;

  /// This id is used for dismissing posts from blocked users
  final int? dismissBlockedUserId;

  /// This id is used for dismissing posts from blocked communities
  final int? dismissBlockedCommunityId;

  /// This id is used for dismissing posts that have been hidden by the user
  final int? dismissHiddenPostId;

  FeedUiState copyWith({
    int? scrollId,
    int? dismissReadId,
    int? dismissBlockedUserId,
    int? dismissBlockedCommunityId,
    int? dismissHiddenPostId,
  }) {
    return FeedUiState(
      scrollId: scrollId ?? this.scrollId,
      dismissReadId: dismissReadId ?? this.dismissReadId,
      dismissBlockedUserId: dismissBlockedUserId,
      dismissBlockedCommunityId: dismissBlockedCommunityId,
      dismissHiddenPostId: dismissHiddenPostId,
    );
  }

  @override
  List<Object?> get props => [
        scrollId,
        dismissReadId,
        dismissBlockedUserId,
        dismissBlockedCommunityId,
        dismissHiddenPostId,
      ];
}
