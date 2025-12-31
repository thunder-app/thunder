part of 'post_navigation_cubit.dart';

class PostNavigationState extends Equatable {
  const PostNavigationState({
    this.navigateCommentIndex = 0,
    this.highlightedCommentId,
    this.commentSearchResults,
    this.scrollPosition,
    this.didScrollPositionChange = false,
  });

  /// The index of the comment to navigate to
  final int navigateCommentIndex;

  /// The ID of the comment that should be highlighted
  final int? highlightedCommentId;

  /// The search results for comment search (maps comment index to comment ID)
  final Map<int, int>? commentSearchResults;

  /// Saves the position of the user's scrolling while viewing a post
  final double? scrollPosition;

  /// Whether the scroll position changed. If it did not, we don't want to rebuild.
  /// This flag just makes it easier to check without having to access both the old and new [scrollPosition].
  final bool didScrollPositionChange;

  PostNavigationState copyWith({
    int? navigateCommentIndex,
    int? highlightedCommentId,
    Map<int, int>? commentSearchResults,
    double? scrollPosition,
    bool? didScrollPositionChange,
  }) {
    return PostNavigationState(
      navigateCommentIndex: navigateCommentIndex ?? this.navigateCommentIndex,
      highlightedCommentId: highlightedCommentId,
      commentSearchResults: commentSearchResults ?? this.commentSearchResults,
      scrollPosition: scrollPosition ?? this.scrollPosition,
      didScrollPositionChange: didScrollPositionChange ?? this.didScrollPositionChange,
    );
  }

  @override
  List<Object?> get props => [
        navigateCommentIndex,
        highlightedCommentId,
        commentSearchResults,
        scrollPosition,
        didScrollPositionChange,
      ];
}
