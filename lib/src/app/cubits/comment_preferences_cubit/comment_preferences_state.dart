part of 'comment_preferences_cubit.dart';

class CommentPreferencesState extends Equatable {
  const CommentPreferencesState({
    this.defaultCommentSortType = DEFAULT_COMMENT_SORT_TYPE,
    this.collapseParentCommentOnGesture = true,
    this.showCommentButtonActions = false,
    this.commentShowUserInstance = false,
    this.commentShowUserAvatar = false,
    this.combineCommentScores = false,
    this.nestedCommentIndicatorStyle = DEFAULT_NESTED_COMMENT_INDICATOR_STYLE,
    this.nestedCommentIndicatorColor = DEFAULT_NESTED_COMMENT_INDICATOR_COLOR,
  });

  /// The default comment sort type
  final CommentSortType defaultCommentSortType;

  /// Whether the parent comment body should be collapsed when tapped
  final bool collapseParentCommentOnGesture;

  /// Whether to show action buttons for comments
  final bool showCommentButtonActions;

  /// Whether to show the user instance in the comment header
  final bool commentShowUserInstance;

  /// Whether to show the user avatar in the comment header
  final bool commentShowUserAvatar;

  /// Whether to show combined comment scores
  final bool combineCommentScores;

  /// The comment depth indicator style
  final NestedCommentIndicatorStyle nestedCommentIndicatorStyle;

  /// The comment depth indicator color
  final NestedCommentIndicatorColor nestedCommentIndicatorColor;

  CommentPreferencesState copyWith({
    CommentSortType? defaultCommentSortType,
    bool? collapseParentCommentOnGesture,
    bool? showCommentButtonActions,
    bool? commentShowUserInstance,
    bool? commentShowUserAvatar,
    bool? combineCommentScores,
    NestedCommentIndicatorStyle? nestedCommentIndicatorStyle,
    NestedCommentIndicatorColor? nestedCommentIndicatorColor,
  }) {
    return CommentPreferencesState(
      defaultCommentSortType: defaultCommentSortType ?? this.defaultCommentSortType,
      collapseParentCommentOnGesture: collapseParentCommentOnGesture ?? this.collapseParentCommentOnGesture,
      showCommentButtonActions: showCommentButtonActions ?? this.showCommentButtonActions,
      commentShowUserInstance: commentShowUserInstance ?? this.commentShowUserInstance,
      commentShowUserAvatar: commentShowUserAvatar ?? this.commentShowUserAvatar,
      combineCommentScores: combineCommentScores ?? this.combineCommentScores,
      nestedCommentIndicatorStyle: nestedCommentIndicatorStyle ?? this.nestedCommentIndicatorStyle,
      nestedCommentIndicatorColor: nestedCommentIndicatorColor ?? this.nestedCommentIndicatorColor,
    );
  }

  @override
  List<Object?> get props => [
        defaultCommentSortType,
        collapseParentCommentOnGesture,
        showCommentButtonActions,
        commentShowUserInstance,
        commentShowUserAvatar,
        combineCommentScores,
        nestedCommentIndicatorStyle,
        nestedCommentIndicatorColor,
      ];
}
