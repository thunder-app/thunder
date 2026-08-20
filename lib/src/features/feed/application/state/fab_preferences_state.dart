part of 'fab_preferences_cubit.dart';

class FabPreferencesState extends Equatable {
  const FabPreferencesState({
    this.enableFeedsFab = true,
    this.enablePostsFab = true,
    this.enableBackToTop = true,
    this.enableSubscriptions = true,
    this.enableRefresh = true,
    this.enableDismissRead = true,
    this.enableChangeSort = true,
    this.enableNewPost = true,
    this.postFabEnableBackToTop = true,
    this.postFabEnableChangeSort = true,
    this.postFabEnableReplyToPost = true,
    this.postFabEnableRefresh = true,
    this.postFabEnableSearch = true,
    this.feedFabSinglePressAction = FeedFabAction.newPost,
    this.feedFabLongPressAction = FeedFabAction.openFab,
    this.postFabSinglePressAction = PostFabAction.replyToPost,
    this.postFabLongPressAction = PostFabAction.openFab,
    this.enableCommentNavigation = true,
    this.combineNavAndFab = true,
  });

  /// Whether to enable the feed page FAB
  final bool enableFeedsFab;

  /// Whether to enable the post page FAB
  final bool enablePostsFab;

  /// Back to top action (feed page FAB)
  final bool enableBackToTop;

  /// Open subscriptions drawer action (feed page FAB)
  final bool enableSubscriptions;

  /// Refresh feed action (feed page FAB)
  final bool enableRefresh;

  /// Dismiss read posts action (feed page FAB)
  final bool enableDismissRead;

  /// Change sort type action (feed page FAB)
  final bool enableChangeSort;

  /// New post action (feed page FAB)
  final bool enableNewPost;

  /// Back to top action (post page FAB)
  final bool postFabEnableBackToTop;

  /// Change sort type action (post page FAB)
  final bool postFabEnableChangeSort;

  /// Reply to post action (post page FAB)
  final bool postFabEnableReplyToPost;

  /// Refresh post/comment action (post page FAB)
  final bool postFabEnableRefresh;

  /// Search comment action (post page FAB)
  final bool postFabEnableSearch;

  /// The action to perform when the feed page FAB is tapped
  final FeedFabAction feedFabSinglePressAction;

  /// The action to perform when the feed page FAB is long pressed
  final FeedFabAction feedFabLongPressAction;

  /// The action to perform when the post page FAB is tapped
  final PostFabAction postFabSinglePressAction;

  /// The action to perform when the post page FAB is long pressed
  final PostFabAction postFabLongPressAction;

  /// Whether to enable comment navigation on the post page
  final bool enableCommentNavigation;

  /// Whether to combine navigation and FAB on the post page
  final bool combineNavAndFab;

  FabPreferencesState copyWith({
    bool? enableFeedsFab,
    bool? enablePostsFab,
    bool? enableBackToTop,
    bool? enableSubscriptions,
    bool? enableRefresh,
    bool? enableDismissRead,
    bool? enableChangeSort,
    bool? enableNewPost,
    bool? postFabEnableBackToTop,
    bool? postFabEnableChangeSort,
    bool? postFabEnableReplyToPost,
    bool? postFabEnableRefresh,
    bool? postFabEnableSearch,
    FeedFabAction? feedFabSinglePressAction,
    FeedFabAction? feedFabLongPressAction,
    PostFabAction? postFabSinglePressAction,
    PostFabAction? postFabLongPressAction,
    bool? enableCommentNavigation,
    bool? combineNavAndFab,
  }) {
    return FabPreferencesState(
      enableFeedsFab: enableFeedsFab ?? this.enableFeedsFab,
      enablePostsFab: enablePostsFab ?? this.enablePostsFab,
      enableBackToTop: enableBackToTop ?? this.enableBackToTop,
      enableSubscriptions: enableSubscriptions ?? this.enableSubscriptions,
      enableRefresh: enableRefresh ?? this.enableRefresh,
      enableDismissRead: enableDismissRead ?? this.enableDismissRead,
      enableChangeSort: enableChangeSort ?? this.enableChangeSort,
      enableNewPost: enableNewPost ?? this.enableNewPost,
      postFabEnableBackToTop: postFabEnableBackToTop ?? this.postFabEnableBackToTop,
      postFabEnableChangeSort: postFabEnableChangeSort ?? this.postFabEnableChangeSort,
      postFabEnableReplyToPost: postFabEnableReplyToPost ?? this.postFabEnableReplyToPost,
      postFabEnableRefresh: postFabEnableRefresh ?? this.postFabEnableRefresh,
      postFabEnableSearch: postFabEnableSearch ?? this.postFabEnableSearch,
      feedFabSinglePressAction: feedFabSinglePressAction ?? this.feedFabSinglePressAction,
      feedFabLongPressAction: feedFabLongPressAction ?? this.feedFabLongPressAction,
      postFabSinglePressAction: postFabSinglePressAction ?? this.postFabSinglePressAction,
      postFabLongPressAction: postFabLongPressAction ?? this.postFabLongPressAction,
      enableCommentNavigation: enableCommentNavigation ?? this.enableCommentNavigation,
      combineNavAndFab: combineNavAndFab ?? this.combineNavAndFab,
    );
  }

  @override
  List<Object?> get props => [
    enableFeedsFab,
    enablePostsFab,
    enableBackToTop,
    enableSubscriptions,
    enableRefresh,
    enableDismissRead,
    enableChangeSort,
    enableNewPost,
    postFabEnableBackToTop,
    postFabEnableChangeSort,
    postFabEnableReplyToPost,
    postFabEnableRefresh,
    postFabEnableSearch,
    feedFabSinglePressAction,
    feedFabLongPressAction,
    postFabSinglePressAction,
    postFabLongPressAction,
    enableCommentNavigation,
    combineNavAndFab,
  ];
}
