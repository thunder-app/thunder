part of 'post_navigation_cubit.dart';

const _postNavigationUnset = Object();

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
    Object? highlightedCommentId = _postNavigationUnset,
    Object? commentSearchResults = _postNavigationUnset,
    Object? scrollPosition = _postNavigationUnset,
    bool? didScrollPositionChange,
  }) {
    return PostNavigationState(
      navigateCommentIndex: navigateCommentIndex ?? this.navigateCommentIndex,
      highlightedCommentId: identical(highlightedCommentId, _postNavigationUnset) ? this.highlightedCommentId : highlightedCommentId as int?,
      commentSearchResults: identical(commentSearchResults, _postNavigationUnset) ? this.commentSearchResults : commentSearchResults as Map<int, int>?,
      scrollPosition: identical(scrollPosition, _postNavigationUnset) ? this.scrollPosition : scrollPosition as double?,
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
